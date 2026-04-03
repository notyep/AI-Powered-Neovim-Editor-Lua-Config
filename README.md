#Complete, optimal, ready-to-run Lua Config for the NeoVIM VI editor (the greatest VI editor on the planet) on Ubuntu 24.04.
I designed it to be:Local-first & private (runs 100% offline with Ollama)
Zero extra dependencies beyond curl (already on Ubuntu)
Feels exactly like classic vi — you type natural language right where you expect the : prompt
Safe — always shows you the exact Vim/Neovim command before running it
Newbie-friendly — teaches real Vim syntax while doing the work for you
*NOTE* You can run this on a modest 6 core CPU system with 16GB of RAM with atleast 25GB of extra disk space for llama3.2 (won't be that fast but will work).
The more hp the better! 

## ❤️ Support the Project

This software is completely free and open-source. I maintain it in my spare time because I love building tools that help developers.

If you find it useful and want to help sustain ongoing development, bug fixes, and new features, please consider [sponsoring me on GitHub Sponsors](https://github.com/sponsors/notyep)!

Every contribution—big or small—makes a real difference.

[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-ff69b4)](https://github.com/sponsors/notyep)

# 1. Update system
sudo apt update && sudo apt upgrade -y

# 2. Install latest Neovim (0.10+ recommended — Ubuntu's default 0.9.5 works but this is better)
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install neovim -y

# 3. Install Ollama + a fast model perfect for command translation
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.2:3b   # super fast & excellent at Vim commands
# (optional faster alternative: ollama pull qwen2.5-coder:1.5b)

# 4. Create the Neovim config directory
mkdir -p ~/.config/nvim
# 5. Save the source as the following :
~/.config/nvim/init.lua

This is a complete, self-contained config — no plugin manager needed for the core feature.

How to use it Open Neovim: "nvim file.txt"
Type :AI delete every line that contains TODO
Or press <Space>ai (leader is Space by default)
The AI instantly translates → shows you the exact command → you confirm or edit

