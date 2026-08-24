#===============================================================================
# FILE: Makefile
# Project: konversation-nix
#===============================================================================


#===============================================================================
# PHONY
#===============================================================================

.PHONY: all clean env homeconf


#===============================================================================
# persistent storage
#===============================================================================

# dofiles directory
DOTFILES_DIR 	:= dotfiles
CACHE_DIR    	:= $(DOTFILES_DIR)/cache
CONFIG_DIR	:= $(DOTFILES_DIR)/config
LOCAL_DIR	:= $(DOTFILES_DIR)/local
FONTCONFIG_DIR  := $(CONFIG_DIR)/fontconfig

# Application Configuration Paths
NIX_DIR		:= $(CONFIG_DIR)/nix
NIX_FILE	:= $(NIX_DIR)/nix.conf
ENV_FILE     	:= .env

# Home Manager Paths
HOME_MANAGER_DIR := $(CONFIG_DIR)/home-manager
FLAKE_NIX        := $(HOME_MANAGER_DIR)/flake.nix
HOME_NIX         := $(HOME_MANAGER_DIR)/home.nix
NIX_VERSION	 := 26.05


#===============================================================================
# default target
#===============================================================================

all: env homeconf


#===============================================================================
# create directories
#===============================================================================

dotfiles: 
	mkdir -p $(DOTFILES_DIR)


config: dotfiles
	mkdir -p $(CONFIG_DIR)


local: config
	mkdir -p $(LOCAL_DIR)


#===============================================================================
# nix
#===============================================================================

nixdir: local
	mkdir -p $(NIX_DIR)

#===============================================================================
# fontconfig
#===============================================================================

fontconfig: nixdir
	mkdir -p $(FONTCONFIG_DIR)
	printf "%s\n" \
	'<?xml version="1.0"?>' \
	'<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">' \
	'<fontconfig>' \
	'  <cachedir>~/.cache/fontconfig</cachedir>' \
	'  <dir>~/.local/share/fonts</dir>' \
	'  <include ignore_missing="yes">~/.config/fontconfig/conf.d</include>' \
	'  <match target="font">' \
	'    <edit name="antialias" mode="assign"><bool>true</bool></edit>' \
	'    <edit name="hinting" mode="assign"><bool>true</bool></edit>' \
	'    <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>' \
	'  </match>' \
	'</fontconfig>' > $(FONTCONFIG_DIR)/fonts.conf


#===============================================================================
# nix flakes
#===============================================================================

nixconf: fontconfig
	@_USER=`id -un`; \
	printf "%s\n" \
	"experimental-features = nix-command flakes" \
	"filter-syscalls = false" \
	"sandbox = false" \
	"trusted-users = root $${_USER}" > $(NIX_FILE)


#===============================================================================
# cache
#===============================================================================

cache: nixconf
	mkdir -p $(CACHE_DIR)


#===============================================================================
# Environment Configuration Target
# Generates a personalized .env file automatically
#===============================================================================

env: cache
	@_USER=`id -un`; \
	_UID=`id -u`; \
	_HOST=`hostname -s`; \
	_MNT=""; \
	for _dir in Downloads Download downloads download; do \
		if [ -d "/home/$$_USER/$$_dir" ]; then \
			_MNT="/home/$$_USER/$$_dir"; \
			break; \
		fi; \
	done; \
	if [ -z "$$_MNT" ]; then \
		_MNT="/home/$$_USER/downloads"; \
	fi; \
	printf "%s\n" \
	"#===============================================================================" \
	"# FILE: .env" \
	"# Project: konversation-nix" \
	"#===============================================================================" \
	"" \
	"" \
	"#===============================================================================" \
	"# XDG_RUNTIME_DIR" \
	"#===============================================================================" \
	"" \
	"HOST_XDG_RUNTIME_DIR=\$${XDG_RUNTIME_DIR}" \
	"" \
	"" \
	"#===============================================================================" \
	"# XDG_SESSION_TYPE" \
	"#===============================================================================" \
	"" \
	"HOST_XDG_SESSION_TYPE=\$${XDG_SESSION_TYPE}" \
	"" \
	"" \
	"#===============================================================================" \
	"# DBUS_SESSION_BUS_ADDRESS" \
	"#===============================================================================" \
	"" \
	"HOST_DBUS_SESSION_BUS_ADDRESS=\$${DBUS_SESSION_BUS_ADDRESS}" \
	"" \
	"" \
	"#===============================================================================" \
	"# HOST_UID (Automatically detected from FreeBSD)" \
	"#===============================================================================" \
	"" \
	"HOST_UID=$$_UID" \
	"" \
	"" \
	"#===============================================================================" \
	"# HOST_USER (Automatically detected from FreeBSD)" \
	"#===============================================================================" \
	"" \
	"HOST_USER=$$_USER" \
	"" \
	"" \
	"#===============================================================================" \
	"# HOST_HOSTNAME (Automatically detected from FreeBSD)" \
	"#===============================================================================" \
	"" \
	"HOST_HOSTNAME=$$_HOST" \
	"" \
	"" \
	"#===============================================================================" \
	"# HOST_BIN" \
	"# Bin directory mounted into the container" \
	"#===============================================================================" \
	"" \
	"HOST_BIN=bin" \
	"" \
	"" \
	"#===============================================================================" \
	"# HOST_MOUNT" \
	"# Directory mounted from FreeBSD into the container" \
	"#===============================================================================" \
	"" \
	"HOST_MOUNT=$$_MNT" \
	"" \
	"" \
	"#===============================================================================" \
	"# HOST_LANG (Host language)" \
	"#===============================================================================" \
	"" \
	"HOST_LANG=$${LANG}" > $(ENV_FILE);


#===============================================================================
# Home Manager Flake & Config Target
#===============================================================================

homeconf: env
	@_USER=`id -un`; \
	_HOST=`hostname -s`; \
	mkdir -p $(HOME_MANAGER_DIR); \
	printf "%s\n" \
	"{" \
	"  description = \"Home Manager configuration\";" \
	"" \
	"  inputs = {" \
	"    nixpkgs.url = \"github:nixos/nixpkgs/nixos-unstable\";" \
	"    nixpkgs-stable.url = \"github:nixos/nixpkgs/nixos-$(NIX_VERSION)\";" \
	"    nixpkgs-master.url = \"github:nixos/nixpkgs/master\";" \
	"" \
	"    home-manager = {" \
	"      url = \"github:nix-community/home-manager\";" \
	"      inputs.nixpkgs.follows = \"nixpkgs\";" \
	"    };" \
	"  };" \
	"" \
	"  outputs = inputs@{" \
	"    self," \
	"    nixpkgs," \
	"    nixpkgs-stable," \
	"    nixpkgs-master," \
	"    home-manager," \
	"    ... }:" \
	"    let" \
	"      system = \"x86_64-linux\";" \
	"      username = \"$${_USER}\";" \
	"      hostname = \"$${_HOST}\";" \
	"    in" \
	"    {" \
	"      homeConfigurations.\"\$${username}@\$${hostname}\" = home-manager.lib.homeManagerConfiguration {" \
	"        pkgs = nixpkgs.legacyPackages.\$${system};" \
	"        " \
	"        extraSpecialArgs = {" \
	"          pkgs-stable = import nixpkgs-stable {" \
	"            inherit system;" \
	"            config.allowUnfree = true;" \
	"            system-openssl = true;" \
	"          };" \
	"          pkgs-master = import nixpkgs-master {" \
	"            inherit system;" \
	"            config.allowUnfree = true;" \
	"          };" \
	"        };" \
	"        " \
	"        modules = [" \
	"          ./home.nix" \
	"        ];" \
	"      };" \
	"    };" \
	"}" > $(FLAKE_NIX); \
printf "%s\n" \
	"{" \
	"  config," \
	"  pkgs," \
	"  pkgs-stable," \
	"  pkgs-master," \
	"  ..." \
	"}: let" \
	"  fonts = with pkgs; [" \
	"    dejavu_fonts" \
	"    liberation_ttf" \
	"    noto-fonts" \
	"    cantarell-fonts" \
	"  ];" \
	"" \
	"  fontsConf = pkgs.makeFontsConf {" \
	"    fontDirectories = fonts;" \
	"  };" \
	"in {" \
	"  home.username = \"$${_USER}\";" \
	"  home.homeDirectory = \"/home/$${_USER}\";" \
	"  home.stateVersion = \"$(NIX_VERSION)\";" \
	"" \
	"  nixpkgs.config.allowUnfree = true;" \
	"  fonts.fontconfig.enable = true;" \
	"" \
	"  home.packages = with pkgs; [" \
	"    adwaita-qt6" \
	"    adwaita-icon-theme" \
	"    qt6Packages.qt6ct" \
	"    kdePackages.kglobalaccel" \
	"    pipewire" \
	"    fontconfig" \
	"    kdePackages.konversation" \
	"  ] ++ fonts;" \
	"" \
	"  # qt" \
	"  qt = {" \
	"      enable = true;" \
	"      platformTheme.name = \"adwaita\";"\
	"      style = {" \
	"        name = \"adwaita-dark\";" \
	"        package = pkgs.adwaita-qt6;" \
	"     };" \
	"  };" \
	"" \
	"  home.file = {};" \
	"" \
	"  home.sessionVariables = {};" \
	"" \
	"  programs.home-manager.enable = true;" \
	"}" > $(HOME_NIX)


#===============================================================================
# Clean target to wipe the structure out if you need to reset
#===============================================================================

clean:
	rm -rf $(DOTFILES_DIR)
	rm -rf $(WORKSPACE_DIR)
	rm -f $(ENV_FILE)
