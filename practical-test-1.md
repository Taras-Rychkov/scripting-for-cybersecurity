# Scripting for Cybersecurity — Practical Test 1

**Duration:** 120 minutes
**Total marks:** 100
**Environment:** Linux terminal with Bash, GitHub Codespaces

## Rules

- You may use `man` pages and each command's `--help` output.

- Your own Github lab repository and notes can be used during the test.

- Github Codespaces can be used during the test.

- Internet access, AI tools, and communication with other people are not permitted during the test, except for the initial download of the test data and the submission of the results by committing them to the repository.

- A script that does not run, or that crashes, can still earn partial marks, so submit everything you write.

- Please run the following script command on terminal at the beginning of the test to record all the commands you will type.
  
  ```bash
  script --timing=time.log session.log
  ```

- Please run the following script command on terminal at the end of the test.
  
  ```bash
  exit
  ```

## Setup (not marked)

Please download the exam-data folder here: https://github.com/robustness/Test1

```bash
cd ~
gh repo clone robustness/Test1
cd Test1
```

```text
exam-data/
├── case/
│   ├── backups/          old backup copies of files
│   ├── configs/          configuration files
│   ├── docs/             inventory
│   ├── evidence/         files collected from the server
│   ├── logs/             auth.log (SSH), access.log (web server), firewall.log
│   ├── nested/archive/   older logs
│   ├── scripts/          scripts collected from the server (do NOT run them)
│   ├── config-new.txt, config-old.txt, hello.sh, windows.sh
└── intel/                iocs.txt (indicators of compromise), users.csv (accounts),
                          and longer copies of auth.log and access.log
```

**All your scripts and your `answers.txt` go directly in `~/Test1`**. Every script must be run from `~/Test1`, and must refer to the data with relative paths that start with `exam-data/`.

## The scenario

The server (`server`, 10.0.0.10) was reported for suspicious activity on 20 September 2026. Its logs, configuration files and some files from its disk have been collected into `exam-data/case/`, and threat intelligence and the account list are in `exam-data/intel/`. Your job is to triage the collection with command-line tools and scripts.

Unless a question says otherwise, "the logs" means the files in `exam-data/case/logs/`.

---

# Section A: Command-line triage (16 marks)

Create a file called `answers.txt`. For **each** question, record the command (or pipeline) you used **and** its result, in this format:

```text
A1
Command: <your command>
Answer: <the result>
```

Each question is worth 2 marks: 1 for a correct command, 1 for the correct answer. A single command or pipeline is expected for each question.

**A1.** How many **regular files** are there in `exam-data`, at any depth?

**A2.** Which file(s) in `exam-data` are **empty** (0 bytes)? 

**A3.** Use `file` to identify the real type of every file in `exam-data/case/evidence`. Find at least **one** file that has content mismatching its extension, and what is it really?

**A4.** How many **failed** password attempts are recorded in `exam-data/case/logs/auth.log`?

**A5.** List the **three** source IP addresses with the most failed password attempts in `exam-data/case/logs/auth.log`, with their counts, busiest first.

**A6.** List every HTTP status code in `exam-data/case/logs/access.log` with the number of times it occurs, most frequent first. (The status code is the 9th whitespace-separated field.)

**A7.** Which accounts in `exam-data/intel/users.csv` have the status `disabled`? Output the usernames only.

**A8.** Find **every** `.log` file in `exam-data`, at any depth, and show the number of lines in each, using `find ... -print0` together with `xargs -0`.

---

# Section B: Scripts (80 marks)

Each script must:

- start with a correct shebang line;
- be executable;
- quote variables that hold file names or user input;
- send error messages to standard error.

## B1. `logsummary.sh` (15 marks)

Write `logsummary.sh`, which takes **one** log file as an argument and prints a short summary.

1. If the number of arguments is not exactly one, print a usage message and exit with code **1**.

2. If the file does not exist, print an error and exit with code **2**.

3. If the file exists but is **empty**, print an error and exit with code **3**.

4. Otherwise print, each on its own line, using command substitution:
   
   - the file name;
   
   - the number of lines;
   
   - the number of `Failed password` lines;
   
   - the number of `Accepted password` lines;
   
   - the timestamp of the **first** line and of the **last** line (the first three fields of each line);

5. and exit with code **0**.

Example output for `./logsummary.sh exam-data/case/logs/auth.log`:

```text
File     : exam-data/case/logs/auth.log
Lines    : ...
Failed   : ...
Accepted : ...
First    : Sep 20 ...
Last     : Sep 20 ...
```

Test it with `exam-data/case/logs/auth.log`, with `exam-data/case/evidence/empty.bin`, with a file name that does not exist, and with no arguments. Check each exit code with `echo $?`.  Write down the answers to `answers.txt`.

## B2. `check_ip.sh` (20 marks)

Write `check_ip.sh`, which takes **one** IP address as an argument and investigates it.

1. If there is not exactly one argument, or the argument does not look like an IPv4 address (four groups of digits separated by dots), print an error and exit with code **1**.

2. Count the `Failed password` lines and the `Accepted password` lines for that **exact** address in `exam-data/case/logs/auth.log`. Make sure that searching for `203.0.113.1` would **not** also count lines for `203.0.113.10` or `203.0.113.15`.

3. Classify the number of failed attempts with an `if` / `elif` / `else` chain:
   
   | Failed attempts | Risk   |
   | --------------- | ------ |
   | 0               | NONE   |
   | 1–4             | LOW    |
   | 5–9             | MEDIUM |
   | 10 or more      | HIGH   |

4. Print whether the address is listed in `exam-data/intel/iocs.txt` (`IOC : yes` or `IOC : no`). It must be an exact, whole-line match.

5. Print every line in `exam-data/case/logs/firewall.log` for that address, or `Firewall : no entries` if there are none.

6. If the address has **both** failed and accepted logins, print `WARNING: successful login after failed attempts`.

7. Exit with code **0** if the address appears in any file in `exam-data/case/logs`, or code **3** if it appears nowhere.

Run it for `203.0.113.10`, `198.51.100.77`, `192.168.1.20`, `203.0.113.1` and `abc`.
Write down the answers to `answers.txt`.

**Question B2(q)** (in `answers.txt`): Compare your script's output for `203.0.113.10` and `198.51.100.77`. Which of the two addresses represents the bigger gap in the server's defences? Explain in two or three sentences, using your script's output.

## B3. `sweep.sh` (20 marks)

Write `sweep.sh` (no arguments), which does two things.

**Part 1: IOC sweep.** Using **nested `for` loops**, check every indicator in `exam-data/intel/iocs.txt` against every file matching `exam-data/case/logs/*.log`.

- For each indicator and log where the indicator appears, print the indicator, the log's file name (without the directory) and the number of matching lines. Match indicators as fixed strings and whole words.
- After each indicator, print how many logs it was seen in.
- At the end, print the total number of matching lines across all indicators and logs.
- Your script must not print errors or wrong totals when an indicator matches nothing.

**Part 2: hash check.** Using a `for` loop over `exam-data/case/evidence/*`, calculate the **MD5** hash of every regular file and print `KNOWN BAD: <file>` if the hash is a line in `iocs.txt`, or `clean : <file>` otherwise. Your loop must still work correctly if a file name contains a space.

**Question B3(q)** (in `answers.txt`): Run `md5sum exam-data/case/evidence/empty.bin`. A colleague suggests adding this hash to `iocs.txt` because `empty.bin` looks suspicious. What is this hash, and why would it be a bad indicator to act on? 

Write down the answers to `answers.txt`.

## B4. `accounts.sh` and `find_logs.sh` (25 marks)

**Part 1: `accounts.sh` (15 marks).** Using a `while IFS=',' read -r ...` loop over `exam-data/intel/users.csv`:

1. Skip the header line.

2. For each account, print the username, role, status, department and the number of `Accepted password` lines for that user in `exam-data/case/logs/auth.log`, in the format:
   
   ```text
   alice | student | active | Computing | logins: N
   ```
   
   The department must be printed **without** any hidden trailing characters. (Hint: inspect the file with `cat -A`.)

3. If a **disabled** account has one or more successful logins, print an `ALERT` line for it.

4. At the end, print the number of active and disabled accounts.

**Part 2: `find_logs.sh` (10 marks).** Write a script that finds **every** `.log` file under `exam-data`, at any depth, using `find ... -print0` and a `while IFS= read -r -d ''` loop. For each log print its name and line count, and at the end print the number of logs found and the total number of lines.

The final totals **must** be correct when printed after the loop.

**Question B4(q)** (in `answers.txt`): Did your script print any `ALERT`? Now look at the usernames in the `Failed password` lines of `exam-data/case/logs/auth.log`: which account is targeted most, and is it in `users.csv`? What does this suggest about the attack, and what should happen next?

---

# Section C: Submit (4 marks)

Make sure all scripts and `answers.txt` are in the `~/Test1` folder.

Commit the `Test1` folder, including all scripts, `answers.txt`, `time.log`, and `session.log`, to your existing module repository.

# End of Test
