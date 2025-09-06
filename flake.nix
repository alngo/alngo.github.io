{
  description = "Build the blog";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/22.11";
  };
  outputs = inputs: with inputs; let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };

    # Utility to run a script easily in the flakes app
    simple_script = name: add_deps: text: let
      exec = pkgs.writeShellApplication {
        inherit name text;
        runtimeInputs = with pkgs; [
            gnumake     # Required by some dependencies in order to build
            bundler
        ] ++ add_deps;
      };
    in {
      type = "app";
      program = "${exec}/bin/${name}";
    };

  in {
    apps.${system} = {
      default = simple_script "serve_blog" [] ''
        # nix run -> Serve the website locally
      '';

      generate = simple_script "generate_blog_env" [] ''
          # nix run .#generate
          #   Will be used to re-generate the Ruby environment after modifying
          #     a dependency, the version number, etc ...
      '';
    };
  };
}

