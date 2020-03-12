{
  pkgs ? import <nixpkgs> {}
  , hydraDir ? toString ../hydra
  , bagDir ? toString ./.
}:

let
  inherit (pkgs) system writeText;
  release = import "${hydraDir}/release.nix" { shell = true; };

  waitForPg = ''(until echo '\q' | psql -U hydra; do sleep 1; done)'';

  initProcfile = writeText "hydra-in-a-bag-Procfile" ''
    db:         exec bash ${bagDir}/dev-database
    # Ugly, this sleeps after the first posgresql connection only to ensure
    # the pg_setup parts of dev-database had time to init stuff properly.
    init:       ${waitForPg}; sleep 10; exec hydra-init
  '';

  procfile = writeText "hydra-in-a-bag-Procfile" ''
    db:         exec bash ${bagDir}/dev-database
    web:        ${waitForPg}; exec hydra-dev-server --debug --restart
    evaluator:  ${waitForPg}; exec hydra-evaluator
    queue:      ${waitForPg}; exec hydra-queue-runner
  '';

  envfile = writeText "hydra-in-a-bag-env" ''
    PGHOST=${bagDir}/_db/server
    HYDRA_HOME=${hydraDir}/src
    HYDRA_DATA=${bagDir}/_data
    HYDRA_CONFIG=${bagDir}/_data/hydra.conf
    HYDRA_DBI="dbi:Pg:dbname=hydra;host=localhost;user=hydra;"
  '';
in
  release.build.${system}.overrideAttrs(old: {
  buildInputs = with pkgs; [
    foreman
  ] ++ old.buildInputs;

  shellHook = ''
    # Oof, this dance is weird, but this is because the hydra development shell hook
    # assumes $(pwd) is the hydra directory.
    _pwd=$PWD
    cd ${hydraDir}
    ${old.shellHook}
    cd $_pwd
    unset _pwd

    make-hydra() {
      set -e
      (
      echo ":: Building hydra"
      cd ${hydraDir}
      ./bootstrap
      configurePhase
      make
      echo ":: Done building hydra"
      )
      set +e
    }
    dev-database() {
      (
      source ${envfile}
      exec bash ${bagDir}/dev-database
      )
    }
    init-database() {
      make-hydra
      echo ":: Database initialisation"
      foreman start -e ${envfile} -d ${bagDir} -f ${initProcfile}
    }
    start() {
      make-hydra
      echo ":: Starting hydra"
      exec foreman start -e ${envfile} -d ${bagDir} -f ${procfile}
    }
  '';
})
