{ lib
, rustPlatform
, fetchFromGitHub
, protobuf
, stdenv
, pkg-config
, openssl
, rust-jemalloc-sys
, nix-update-script
, Security
}:

rustPlatform.buildRustPackage rec {
  pname = "qdrant";
  version = "1.7.3";

  src = fetchFromGitHub {
    owner = "qdrant";
    repo = "qdrant";
    rev = "refs/tags/v${version}";
    sha256 = "sha256-5c8lQ1CTtYjzrIfHev5aq1FbfctKr5UXylZzzJtyo+o=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "quantization-0.1.0" = "sha256-ggVqJiftu0nvyEM0dzsH0JqIc/Z1XILyUSKiJHeuuZs=";
      "tonic-0.9.2" = "sha256-ZlcDUZy/FhxcgZE7DtYhAubOq8DMSO17T+TCmXar1jE=";
      "wal-0.1.2" = "sha256-nBGwpphtj+WBwL9TmWk7qXiEqlIWkgh/2V9uProqhMk=";
    };
  };

  # Needed to get openssl-sys to use pkg-config.
  OPENSSL_NO_VENDOR = 1;

  buildInputs = [
    openssl
    rust-jemalloc-sys
  ] ++ lib.optionals stdenv.isDarwin [ Security ];

  nativeBuildInputs = [ protobuf rustPlatform.bindgenHook pkg-config ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-faligned-allocation";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Vector Search Engine for the next generation of AI applications";
    longDescription = ''
      Expects a config file at config/config.yaml with content similar to
      https://github.com/qdrant/qdrant/blob/master/config/config.yaml
    '';
    homepage = "https://github.com/qdrant/qdrant";
    license = licenses.asl20;
    maintainers = with maintainers; [ dit7ya ];
  };
}
