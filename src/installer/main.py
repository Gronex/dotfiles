import argparse

from modules import install_module, list_modules


def main():
    parser = argparse.ArgumentParser(description="Dotfiles installation")

    subparsers = parser.add_subparsers()
    list_command_args(subparsers)
    install_command_args(subparsers)

    args = parser.parse_args()
    if "func" in args:
        args.func(args)
    else:
        parser.print_help()


def list_command_args(parser: argparse._SubParsersAction[argparse.ArgumentParser]):
    command_parser = parser.add_parser(
        "list", description="List modules available to install"
    )
    command_parser.add_argument(
        "-v", "--verbose", help="list details if available", action="store_true"
    )
    command_parser.set_defaults(func=list)


def list(args):
    modules = list_modules()

    for module in modules:
        print(module.name)

        if args.verbose:
            if module.description:
                print(module.description)
            print()


def install_command_args(parser: argparse._SubParsersAction[argparse.ArgumentParser]):
    command_parser = parser.add_parser(
        "install", description="Install one or more modules"
    )
    command_parser.add_argument(
        "module", help="module to install", nargs="?", default=None
    )
    command_parser.add_argument(
        "-n",
        "--dry-run",
        help="don't perform filesystem modifications",
        action="store_true",
    )
    command_parser.set_defaults(func=install)


def install(args):
    modules = list_modules()
    if args.module:
        module = next((x for x in modules if args.module == x.name), None)
        if not module:
            print(f"No module named {args.module}")
            return
        modules = [module]

    print(f"Installing modules {', '.join([module.name for module in modules])}")

    for module in modules:
        print(f"Installing {module.name}")
        install_module(module, args.dry_run)


if __name__ == "__main__":
    main()
