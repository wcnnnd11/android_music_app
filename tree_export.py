from pathlib import Path

ROOT_DIR = Path(r"E:\moblie\music_app")
OUTPUT_FILE = "folder_tree.txt"

# 只导出这两个目录
TARGET_DIRS = ["lib", "backend"]

IGNORE_DIRS = {
    ".git",
    "build",
    ".dart_tool",
    ".idea",
    "__pycache__",
    "node_modules",
    ".gradle",
    ".vscode",
    ".pytest_cache",
    ".mypy_cache",
    "dist",
    "out",
}

IGNORE_FILES = {
    ".DS_Store",
}


def generate_tree(path: Path, prefix: str = "") -> list[str]:
    lines = []

    try:
        items = sorted(
            [
                x for x in path.iterdir()
                if x.name not in IGNORE_DIRS and x.name not in IGNORE_FILES
            ],
            key=lambda x: (x.is_file(), x.name.lower())
        )
    except PermissionError:
        return [prefix + "└── [无权限访问]"]

    total = len(items)
    for i, item in enumerate(items):
        is_last = i == total - 1
        connector = "└── " if is_last else "├── "
        lines.append(prefix + connector + item.name)

        if item.is_dir():
            extension = "    " if is_last else "│   "
            lines.extend(generate_tree(item, prefix + extension))

    return lines


def main():
    if not ROOT_DIR.exists():
        print(f"路径不存在: {ROOT_DIR}")
        return

    result = [ROOT_DIR.name]

    existing_targets = [
        ROOT_DIR / name for name in TARGET_DIRS if (ROOT_DIR / name).exists()
    ]

    if not existing_targets:
        print("未找到 lib 或 backend 目录")
        return

    for idx, target in enumerate(existing_targets):
        is_last_target = idx == len(existing_targets) - 1
        connector = "└── " if is_last_target else "├── "
        result.append(connector + target.name)

        extension = "    " if is_last_target else "│   "
        result.extend(generate_tree(target, extension))

    Path(OUTPUT_FILE).write_text("\n".join(result), encoding="utf-8")
    print(f"目录树已导出到: {Path(OUTPUT_FILE).resolve()}")


if __name__ == "__main__":
    main()