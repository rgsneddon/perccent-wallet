import re
from pathlib import Path

path = Path("lib/l10n/app_localizations.dart")
text = path.read_text(encoding="utf-8")
text = re.sub(r"  'fcg_[^']+':[^,\n]*,\n", "", text)
text = re.sub(
    r"  'fcg_[^']+':\n      '[^']*',\n",
    "",
    text,
)
if "'credit_governance_paper'" not in text:
    text = text.replace(
        "  'wallet_app_title': 'Perccent Wallet',\n",
        "  'wallet_app_title': 'Perccent Wallet',\n"
        "  'credit_governance_paper': 'FCG white paper',\n",
    )
path.write_text(text, encoding="utf-8", newline="\n")
print("stripped fcg keys")