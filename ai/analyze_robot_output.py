import os
import json
import re
import xml.etree.ElementTree as ET
from datetime import datetime

OUTPUT_FILE = os.path.join("reports", "output.xml")
OUT_JSON = os.path.join("reports", "ai_summary.json")
OUT_MD = os.path.join("reports", "ai_summary.md")


def classify_error(message: str) -> str:
    """
    Mini IA (approche simple) :
    on classe l'échec selon des mots-clés.
    """
    m = (message or "").lower()

    # Locator / Element not found
    locator_patterns = [
        "no such element",
        "element not found",
        "unable to locate",
        "stale element",
        "element is not attached",
        "invalid selector",
        "xpath",
        "css selector",
    ]
    if any(p in m for p in locator_patterns):
        return "Locator issue (UI change / selector)"

    # Timeout / performance / wait
    timeout_patterns = [
        "timeout",
        "timed out",
        "waiting for",
        "expected condition",
        "page load",
    ]
    if any(p in m for p in timeout_patterns):
        return "Timeout / performance issue"

    # Assertion / functional bug
    assertion_patterns = [
        "assertionerror",
        "should be",
        "should contain",
        "expected",
        "but was",
        "not equal",
    ]
    if any(p in m for p in assertion_patterns):
        return "Functional bug (assertion mismatch)"

    # Environment / browser / driver
    env_patterns = [
        "session not created",
        "chrome not reachable",
        "disconnected",
        "unknown error",
        "net::",
        "browser",
        "driver",
    ]
    if any(p in m for p in env_patterns):
        return "Environment / browser issue"

    return "Unknown"


def normalize_message(message: str) -> str:
    """
    Nettoyage simple pour regrouper les erreurs similaires.
    Ex: enlever les ids dynamiques / numéros.
    """
    if not message:
        return ""
    msg = message.strip()
    msg = re.sub(r"\b\d+\b", "<N>", msg)  # remplace les nombres
    msg = re.sub(r"0x[0-9a-fA-F]+", "0x<HEX>", msg)  # adresse mémoire
    return msg


def analyze_robot_output():
    if not os.path.exists(OUTPUT_FILE):
        print("❌ Fichier reports/output.xml introuvable. Lance d'abord: robot -d reports tests")
        return

    tree = ET.parse(OUTPUT_FILE)
    root = tree.getroot()

    failed = []
    for test in root.iter("test"):
        status = test.find("status")
        if status is not None and status.attrib.get("status") == "FAIL":
            test_name = test.attrib.get("name", "Unknown Test")
            raw_message = status.text.strip() if status.text else "No error message"
            category = classify_error(raw_message)

            failed.append({
                "test_name": test_name,
                "category": category,
                "message": raw_message,
                "message_norm": normalize_message(raw_message),
            })

    # Stats
    counts = {}
    for f in failed:
        counts[f["category"]] = counts.get(f["category"], 0) + 1

    summary = {
        "generated_at": datetime.now().isoformat(timespec="seconds"),
        "total_failed": len(failed),
        "categories": counts,
        "failures": failed,
    }

    # Sauvegarde JSON
    os.makedirs("reports", exist_ok=True)
    with open(OUT_JSON, "w", encoding="utf-8") as fp:
        json.dump(summary, fp, ensure_ascii=False, indent=2)

    # Sauvegarde Markdown (pour LinkedIn / lecture rapide)
    lines = []
    lines.append("# AI Summary - Robot Framework Results\n")
    lines.append(f"- Generated at: {summary['generated_at']}")
    lines.append(f"- Total failed tests: {summary['total_failed']}\n")

    if summary["total_failed"] == 0:
        lines.append("✅ All tests passed.\n")
    else:
        lines.append("## Failure categories\n")
        for cat, n in sorted(summary["categories"].items(), key=lambda x: x[1], reverse=True):
            lines.append(f"- **{cat}**: {n}")

        lines.append("\n## Failed tests details\n")
        for f in failed:
            lines.append(f"### {f['test_name']}")
            lines.append(f"- Category: **{f['category']}**")
            lines.append(f"- Message: `{f['message_norm']}`\n")

    with open(OUT_MD, "w", encoding="utf-8") as fp:
        fp.write("\n".join(lines))

    print("✅ AI Summary generated:")
    print(f" - {OUT_JSON}")
    print(f" - {OUT_MD}")


if __name__ == "__main__":
    analyze_robot_output()