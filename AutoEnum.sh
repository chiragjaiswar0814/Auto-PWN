#!/bin/bash

#############################################
# AutoEnum.sh - Automated Enumeration Pipeline
# Author: Penetration Tester
# Description: Automated reconnaissance tool chaining
#############################################

# ANSI Color Codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════╗"
echo "║     AutoEnum - Auto Recon Pipeline       ║"
echo "║     Automated Penetration Testing        ║"
echo "╚═══════════════════════════════════════════╝"
echo -e "${NC}"

# Check if target IP is provided
if [ -z "$1" ]; then
    echo -e "${RED}[-]${NC} Usage: $0 <TARGET_IP>"
    echo -e "${YELLOW}[!]${NC} Example: $0 192.168.1.100"
    exit 1
fi

TARGET_IP=$1

# Validate IP address format
if ! [[ $TARGET_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo -e "${RED}[-]${NC} Invalid IP address format"
    exit 1
fi

echo -e "${GREEN}[+]${NC} Target: ${YELLOW}$TARGET_IP${NC}"
echo ""

# Create directory structure
BASE_DIR="${TARGET_IP}_recon"
NMAP_DIR="$BASE_DIR/nmap"
WEB_DIR="$BASE_DIR/web"
EXPLOITS_DIR="$BASE_DIR/exploits"

echo -e "${BLUE}[*]${NC} Setting up directory structure..."
mkdir -p "$NMAP_DIR" "$WEB_DIR" "$EXPLOITS_DIR" 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[+]${NC} Created directory: $BASE_DIR"
    echo -e "${GREEN}[+]${NC} Subdirectories: nmap/, web/, exploits/"
else
    echo -e "${RED}[-]${NC} Failed to create directories"
    exit 1
fi

echo ""

#############################################
# PHASE 1: NMAP SCANNING
#############################################
echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          PHASE 1: NMAP SCANNING          ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
echo ""

# Check if nmap is installed
if ! command -v nmap &> /dev/null; then
    echo -e "${RED}[-]${NC} Nmap is not installed"
    exit 1
fi

echo -e "${GREEN}[+]${NC} Running Nmap scan (this may take a while)..."
echo -e "${YELLOW}[!]${NC} Command: nmap -sC -sV -oN $NMAP_DIR/initial.txt $TARGET_IP"
echo ""

nmap -sC -sV -oN "$NMAP_DIR/initial.txt" "$TARGET_IP"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}[+]${NC} Nmap scan completed successfully"
    echo -e "${GREEN}[+]${NC} Results saved to: $NMAP_DIR/initial.txt"
else
    echo -e "${RED}[-]${NC} Nmap scan failed"
    exit 1
fi

echo ""

#############################################
# PHASE 2: WEB SERVICE DETECTION
#############################################
echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      PHASE 2: WEB SERVICE DETECTION      ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
echo ""

# Check for open web ports (80, 443, 8080, 8443)
WEB_PORTS_FOUND=false

if grep -qE "80/tcp.*open|443/tcp.*open|8080/tcp.*open|8443/tcp.*open" "$NMAP_DIR/initial.txt"; then
    WEB_PORTS_FOUND=true
    echo -e "${GREEN}[+]${NC} Web services detected!"
    
    # Extract open web ports
    echo -e "${YELLOW}[!]${NC} Open web ports:"
    grep -E "80/tcp.*open|443/tcp.*open|8080/tcp.*open|8443/tcp.*open" "$NMAP_DIR/initial.txt" | while read line; do
        echo -e "    ${GREEN}→${NC} $line"
    done
    echo ""
else
    echo -e "${RED}[-]${NC} No web services detected on common ports"
    echo -e "${YELLOW}[!]${NC} Skipping web enumeration phase"
fi

#############################################
# PHASE 3: WEB ENUMERATION (NIKTO)
#############################################
if [ "$WEB_PORTS_FOUND" = true ]; then
    echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║       PHASE 3: WEB ENUMERATION (NIKTO)   ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
    echo ""
    
    # Check if nikto is installed
    if command -v nikto &> /dev/null; then
        echo -e "${GREEN}[+]${NC} Running Nikto web vulnerability scanner..."
        echo -e "${YELLOW}[!]${NC} Command: nikto -h $TARGET_IP -o $WEB_DIR/nikto.txt"
        echo ""
        
        nikto -h "$TARGET_IP" -o "$WEB_DIR/nikto.txt"
        
        if [ $? -eq 0 ]; then
            echo ""
            echo -e "${GREEN}[+]${NC} Nikto scan completed"
            echo -e "${GREEN}[+]${NC} Results saved to: $WEB_DIR/nikto.txt"
        else
            echo -e "${RED}[-]${NC} Nikto scan encountered errors"
        fi
    else
        echo -e "${RED}[-]${NC} Nikto is not installed"
        echo -e "${YELLOW}[!]${NC} Install with: sudo apt install nikto"
    fi
    
    echo ""
    
    #############################################
    # PHASE 4: DIRECTORY BRUTE-FORCING (GOBUSTER)
    #############################################
    echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║    PHASE 4: DIRECTORY ENUMERATION        ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
    echo ""
    
    # Check if gobuster is installed
    if command -v gobuster &> /dev/null; then
        # Check for common wordlists
        WORDLIST=""
        if [ -f "/usr/share/wordlists/dirb/common.txt" ]; then
            WORDLIST="/usr/share/wordlists/dirb/common.txt"
        elif [ -f "/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt" ]; then
            WORDLIST="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
        fi
        
        if [ -n "$WORDLIST" ]; then
            echo -e "${GREEN}[+]${NC} Running Gobuster directory enumeration..."
            echo -e "${YELLOW}[!]${NC} Wordlist: $WORDLIST"
            echo -e "${YELLOW}[!]${NC} Command: gobuster dir -u http://$TARGET_IP -w $WORDLIST -o $WEB_DIR/gobuster.txt"
            echo ""
            
            gobuster dir -u "http://$TARGET_IP" -w "$WORDLIST" -o "$WEB_DIR/gobuster.txt" -q
            
            if [ $? -eq 0 ]; then
                echo ""
                echo -e "${GREEN}[+]${NC} Gobuster scan completed"
                echo -e "${GREEN}[+]${NC} Results saved to: $WEB_DIR/gobuster.txt"
            else
                echo -e "${RED}[-]${NC} Gobuster scan encountered errors"
            fi
        else
            echo -e "${RED}[-]${NC} No wordlist found"
            echo -e "${YELLOW}[!]${NC} Install wordlists with: sudo apt install wordlists"
        fi
    else
        echo -e "${RED}[-]${NC} Gobuster is not installed"
        echo -e "${YELLOW}[!]${NC} Install with: sudo apt install gobuster"
    fi
fi

echo ""

#############################################
# SUMMARY
#############################################
echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              SCAN SUMMARY                 ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}[+]${NC} Target: ${YELLOW}$TARGET_IP${NC}"
echo -e "${GREEN}[+]${NC} Results directory: ${YELLOW}$BASE_DIR${NC}"
echo ""
echo -e "${BLUE}[*]${NC} Generated files:"
echo -e "    ${GREEN}→${NC} $NMAP_DIR/initial.txt"

if [ "$WEB_PORTS_FOUND" = true ]; then
    [ -f "$WEB_DIR/nikto.txt" ] && echo -e "    ${GREEN}→${NC} $WEB_DIR/nikto.txt"
    [ -f "$WEB_DIR/gobuster.txt" ] && echo -e "    ${GREEN}→${NC} $WEB_DIR/gobuster.txt"
fi

echo ""
echo -e "${GREEN}[+]${NC} Enumeration pipeline completed!"
echo -e "${YELLOW}[!]${NC} Review the results and proceed with exploitation phase"
echo ""
