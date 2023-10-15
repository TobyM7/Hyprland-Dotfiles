#!/bin/bash
curl –proto ‘=https’ –tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
rustup toolchain install nightly
rustup override set nightly
cargo --version
cd /home/$USER
git clone https://github.com/elkowar/eww
cd eww
cargo build --release --no-default-features --features=wayland
cd target/release
chmod +x ./eww
sudo cp eww /usr/bin/
