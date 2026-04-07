{
  buildFishPlugin,
  fzf,
  tree,
  lib,
}:
let
  fs = lib.fileset;
in
buildFishPlugin {
  pname = "lophius";
  version = "0.4.1";

  inputs = [
    fzf
    tree
  ];

  src = fs.toSource {
    root = ./.;
    fileset = fs.unions [
      ./conf.d
      ./functions
    ];
  };

  meta = {
    description = "Tab completion via fzf for fish shell.";
    homepage = "https://github.com/ogaken-1/lophius.fish";
    license = lib.licenses.mit;
  };
}
