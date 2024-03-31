with import <nixpkgs> { };
let
  inherit (llvmPackages_17) stdenv libcxx libcxxabi;
  inherit (darwin.apple_sdk) frameworks;

  CFLAGS = "-mcpu=apple-m1 -O3";
  CXXFLAGS = "${CFLAGS}";
  LDFLAGS = "-fuse-ld=lld";
in mkShell.override { inherit (llvmPackages_17) stdenv; } {
  nativeBuildInputs = [ clang_17 lld_17 llvm_17 ];

  buildInputs = with frameworks;
    [

      Accelerate

    ] ++

    [ libcxx libcxxabi ];

}
