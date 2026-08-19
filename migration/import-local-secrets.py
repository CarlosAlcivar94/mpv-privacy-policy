#!/usr/bin/env python3
import argparse
import base64
import getpass
import json
from pathlib import Path

from cryptography.hazmat.primitives import hashes, padding
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC


def decrypt_bundle(bundle: dict, passphrase: str) -> dict:
    salt = base64.b64decode(bundle["salt"])
    iv = base64.b64decode(bundle["iv"])
    ciphertext = base64.b64decode(bundle["ciphertext"])
    iterations = int(bundle["iterations"])

    kdf = PBKDF2HMAC(
        algorithm=hashes.SHA1(),
        length=32,
        salt=salt,
        iterations=iterations,
    )
    key = kdf.derive(passphrase.encode("utf-8"))

    cipher = Cipher(algorithms.AES(key), modes.CBC(iv))
    decryptor = cipher.decryptor()
    padded = decryptor.update(ciphertext) + decryptor.finalize()

    unpadder = padding.PKCS7(128).unpadder()
    plaintext = unpadder.update(padded) + unpadder.finalize()
    return json.loads(plaintext.decode("utf-8"))


def main() -> int:
    parser = argparse.ArgumentParser(description="Restore KA94 encrypted local secrets on Ubuntu.")
    parser.add_argument("bundle", help="Path to ka94-secrets.bundle.json")
    parser.add_argument("--destination", default=str(Path.home() / "Dev"), help="Clone root directory")
    parser.add_argument("--dry-run", action="store_true", help="Show actions without writing files")
    parser.add_argument("--overwrite", action="store_true", help="Overwrite existing files")
    args = parser.parse_args()

    bundle_path = Path(args.bundle).expanduser()
    destination = Path(args.destination).expanduser()

    with bundle_path.open("r", encoding="utf-8-sig") as handle:
      bundle = json.load(handle)

    passphrase = getpass.getpass("Bundle passphrase: ")
    payload = decrypt_bundle(bundle, passphrase)

    print(f"Bundle created: {payload.get('createdAt')}")
    print(f"Files in bundle: {len(payload.get('files', []))}")

    for file_entry in payload.get("files", []):
        target_root = destination / file_entry["cloneFolder"]
        target_path = target_root / file_entry["relativePath"]

        if not target_root.exists():
            print(f"WARN missing project folder, skipping [{file_entry['project']}]: {target_root}")
            continue

        if target_path.exists() and not args.overwrite:
            print(f"WARN exists, skipping without --overwrite: {target_path}")
            continue

        print(f"Restore [{file_entry['project']}] {file_entry['relativePath']}")
        if args.dry_run:
            continue

        target_path.parent.mkdir(parents=True, exist_ok=True)
        target_path.write_bytes(base64.b64decode(file_entry["contentBase64"]))

    print("Dry run completed." if args.dry_run else "Secrets import completed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
