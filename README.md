# AutoEnum.sh - Automated Enumeration Pipeline

An automated Bash script that chains together multiple Kali Linux reconnaissance tools into a single streamlined penetration testing pipeline.

## 🎯 Features

- **Automated Directory Structure**: Creates organized folders for scan results
- **Multi-Tool Integration**: Chains Nmap, Nikto, and Gobuster automatically
- **Conditional Execution**: Intelligently triggers web enumeration only when web services are detected
- **Visual Feedback**: Color-coded terminal output with status indicators
- **Error Handling**: Validates input and checks for tool availability

## 📋 Prerequisites

### Required Tools
- **Nmap**: Network scanner
- **Nikto**: Web vulnerability scanner (optional)
- **Gobuster**: Directory brute-forcing tool (optional)

### Installation on Kali Linux
```bash
sudo apt update
sudo apt install nmap nikto gobuster wordlists -y
```

## 🚀 Usage

### Basic Usage
```bash
chmod +x AutoEnum.sh
./AutoEnum.sh <TARGET_IP>
```

### Example
```bash
./AutoEnum.sh 192.168.1.100
```

## 📁 Output Structure

The script creates the following directory structure:

```
<TARGET_IP>_recon/
├── nmap/
│   └── initial.txt          # Nmap scan results
├── web/
│   ├── nikto.txt           # Nikto vulnerability scan
│   └── gobuster.txt        # Directory enumeration results
└── exploits/
    └── (reserved for exploitation phase)
```

## 🔄 Pipeline Workflow

### Phase 1: Nmap Scanning
- Runs comprehensive Nmap scan with service detection
- Command: `nmap -sC -sV -oN nmap/initial.txt <TARGET_IP>`
- Flags:
  - `-sC`: Run default NSE scripts
  - `-sV`: Version detection
  - `-oN`: Normal output format

### Phase 2: Web Service Detection
- Parses Nmap results using `grep`
- Checks for open ports: 80, 443, 8080, 8443
- Conditionally triggers web enumeration if web services found

### Phase 3: Nikto Scanning (Conditional)
- Only runs if web ports are detected
- Command: `nikto -h <TARGET_IP> -o web/nikto.txt`
- Identifies web vulnerabilities and misconfigurations

### Phase 4: Directory Enumeration (Conditional)
- Only runs if web ports are detected
- Command: `gobuster dir -u http://<TARGET_IP> -w <WORDLIST> -o web/gobuster.txt`
- Discovers hidden directories and files

## 🎨 Visual Indicators

The script uses ANSI color codes for clear status reporting:

- 🟢 **Green [+]**: Successful operations
- 🔴 **Red [-]**: Errors or failures
- 🟡 **Yellow [!]**: Warnings or important information
- 🔵 **Blue [*]**: Informational messages

## 🔧 Customization

### Modify Nmap Scan Options
Edit line 73 to customize Nmap flags:
```bash
nmap -sC -sV -p- -T4 -oN "$NMAP_DIR/initial.txt" "$TARGET_IP"
```

### Change Wordlist
Edit line 145 to use a different wordlist:
```bash
WORDLIST="/path/to/your/wordlist.txt"
```

### Add More Tools
Add additional phases after Phase 4:
```bash
# PHASE 5: CUSTOM TOOL
echo -e "${BLUE}[*]${NC} Running custom tool..."
your-tool -options "$TARGET_IP" > "$BASE_DIR/custom_output.txt"
```

## ⚠️ Legal Disclaimer

**IMPORTANT**: This tool is designed for authorized penetration testing and educational purposes only.

- ✅ Only use on systems you own or have explicit written permission to test
- ❌ Unauthorized access to computer systems is illegal
- ⚖️ Users are responsible for compliance with all applicable laws

## 📝 Example Output

```
╔═══════════════════════════════════════════╗
║     AutoEnum - Auto Recon Pipeline       ║
║     Automated Penetration Testing        ║
╚═══════════════════════════════════════════╝

[+] Target: 192.168.1.100

[*] Setting up directory structure...
[+] Created directory: 192.168.1.100_recon
[+] Subdirectories: nmap/, web/, exploits/

╔═══════════════════════════════════════════╗
║          PHASE 1: NMAP SCANNING          ║
╚═══════════════════════════════════════════╝

[+] Running Nmap scan (this may take a while)...
[!] Command: nmap -sC -sV -oN 192.168.1.100_recon/nmap/initial.txt 192.168.1.100

[+] Nmap scan completed successfully
[+] Results saved to: 192.168.1.100_recon/nmap/initial.txt

╔═══════════════════════════════════════════╗
║      PHASE 2: WEB SERVICE DETECTION      ║
╚═══════════════════════════════════════════╝

[+] Web services detected!
[!] Open web ports:
    → 80/tcp   open  http    Apache httpd 2.4.41
    → 443/tcp  open  ssl/http Apache httpd 2.4.41

[+] Enumeration pipeline completed!
```

## 🛠️ Troubleshooting

### "Command not found" errors
Install missing tools:
```bash
sudo apt install nmap nikto gobuster -y
```

### Permission denied
Make the script executable:
```bash
chmod +x AutoEnum.sh
```

### Nmap requires root privileges
Run with sudo for full functionality:
```bash
sudo ./AutoEnum.sh 192.168.1.100
```

## 📚 Learning Resources

- [Nmap Documentation](https://nmap.org/book/man.html)
- [Nikto Documentation](https://github.com/sullo/nikto)
- [Gobuster Documentation](https://github.com/OJ/gobuster)

## 🤝 Contributing

Feel free to enhance this script by:
- Adding more reconnaissance tools
- Improving error handling
- Adding parallel scanning capabilities
- Implementing report generation



This project is provided for educational purposes. Use responsibly and ethically.
