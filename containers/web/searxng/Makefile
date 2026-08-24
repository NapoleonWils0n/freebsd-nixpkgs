#===============================================================================
# FILE: Makefile
# Project: searxng-nix
#===============================================================================


#===============================================================================
# PHONY
#===============================================================================

.PHONY: all clean env


#===============================================================================
# persistent storage
#===============================================================================

# dofiles directory
DOTFILES_DIR 	:= dotfiles
CACHE_DIR    	:= $(DOTFILES_DIR)/cache
CONFIG_DIR	:= $(DOTFILES_DIR)/config
LOCAL_DIR	:= $(DOTFILES_DIR)/local

# Application Configuration Paths
NIX_DIR		:= $(CONFIG_DIR)/nix
NIX_FILE	:= $(NIX_DIR)/nix.conf
ENV_FILE     	:= .env

# searxng
SEARXNG_DIR  := $(CONFIG_DIR)/searxng
SEARXNG_CONF := $(SEARXNG_DIR)/settings.yml

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
# nix flakes
#===============================================================================

nixconf: nixdir
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
# searxng
#===============================================================================

searxng: cache
	mkdir -p $(SEARXNG_DIR)

# Generate SearXNG minimal configuration
searxng_cfg: searxng
	printf "%s\n" \
	"use_default_settings: true" \
	"server:" \
	"  port: 8080" \
	"  bind_address: \"0.0.0.0\"" \
	"  secret_key: \"@SEARXNG_SECRET@\"" \
	"search:" \
	"  safe_search: 0" \
	"  autocomplete: google" \
	"  autocomplete_min: 4" \
	"  formats:" \
	"    - html" \
	"    - csv" \
	"    - json" \
	"    - rss" \
	"engines:" \
	"  - name: wikidata" \
	"    disabled: true" \
	"  - name: radio browser" \
	"    disabled: true" \
	"  - name: ahmia" \
	"    disabled: true" \
	"  - name: torch" \
	"    disabled: true" \
	"  - name: brave" \
	"    disabled: true" \
	"  - name: startpage" \
	"    disabled: true" > $(SEARXNG_CONF)

#===============================================================================
# Environment Configuration Target
# Generates a personalized .env file automatically
#===============================================================================

env: searxng_cfg
	@_USER=`id -un`; \
	_UID=`id -u`; \
	_HOST=`hostname -s`; \
	_SECRET=`openssl rand -hex 32`; \
        sed -i "" "s/@SEARXNG_SECRET@/$$_SECRET/g" $(SEARXNG_CONF) 2>/dev/null || sed -i "s/@SEARXNG_SECRET@/$$_SECRET/g" $(SEARXNG_CONF); \
	printf "%s\n" \
	"#===============================================================================" \
	"# FILE: .env" \
	"# Project: searxng-nix" \
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
	"}: {" \
	"  home.username = \"$${_USER}\";" \
	"  home.homeDirectory = \"/home/$${_USER}\";" \
	"  home.stateVersion = \"$(NIX_VERSION)\";" \
	"" \
	"  nixpkgs.config.allowUnfree = true;" \
	"" \
	"home.packages = with pkgs; [" \
	"  searxng" \
	"];" \
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
	rm -f $(ENV_FILE)
