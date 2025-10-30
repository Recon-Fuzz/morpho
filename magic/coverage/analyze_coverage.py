#!/usr/bin/env python3
"""
Analyze Echidna coverage report to identify covered functions in Morpho.sol
"""

import re
import sys

def analyze_morpho_coverage(coverage_file):
    """Parse the coverage file and identify covered lines in Morpho.sol"""

    with open(coverage_file, 'r') as f:
        content = f.read()

    # Find the Morpho.sol section
    morpho_section_match = re.search(
        r'/Users/.*?/src/Morpho\.sol\n(.*?)(?=\n/Users/|\Z)',
        content,
        re.DOTALL
    )

    if not morpho_section_match:
        print("Could not find Morpho.sol in coverage report")
        return

    morpho_section = morpho_section_match.group(1)
    lines = morpho_section.split('\n')

    # Track covered lines (marked with *)
    covered_lines = set()
    uncovered_lines = set()

    # Parse coverage markers
    for line in lines:
        # Match lines like:  22438→  38 | *   | contract Morpho is IMorphoStaticTyping {
        match = re.match(r'\s*\d+→\s+(\d+)\s+\|\s+(\*|\s+)\s+\|', line)
        if match:
            line_num = int(match.group(1))
            is_covered = match.group(2) == '*'

            if is_covered:
                covered_lines.add(line_num)
            else:
                # Only track non-comment, non-empty lines as uncovered
                code_part = line.split('|', 2)[-1].strip()
                if code_part and not code_part.startswith('//'):
                    uncovered_lines.add(line_num)

    print(f"=== Morpho.sol Coverage Analysis ===\n")
    print(f"Total covered lines: {len(covered_lines)}")
    print(f"Total uncovered lines: {len(uncovered_lines)}")
    print(f"Coverage rate: {len(covered_lines)/(len(covered_lines)+len(uncovered_lines))*100:.2f}%\n")

    # Identify key functions and their coverage
    function_patterns = {
        'setOwner': (95, 101),
        'enableIrm': (104, 110),
        'enableLltv': (113, 120),
        'setFee': (123, 136),
        'setFeeRecipient': (139, 145),
        'createMarket': (150, 164),
        'supply': (169, 197),
        'withdraw': (200, 230),
        'borrow': (235, 266),
        'repay': (269, 298),
        'supplyCollateral': (303, 320),
        'withdrawCollateral': (323, 342),
        'liquidate': (347, 417),
        'flashLoan': (422, 432),
        'setAuthorization': (437, 443),
        'setAuthorizationWithSig': (446, 464),
        'accrueInterest': (474, 479),
        '_accrueInterest': (483, 520),
    }

    print("=== Function Coverage Status ===\n")
    for func_name, (start, end) in function_patterns.items():
        func_covered = sum(1 for line in range(start, end+1) if line in covered_lines)
        func_total = end - start + 1
        coverage_pct = (func_covered / func_total * 100) if func_total > 0 else 0
        status = "✓ COVERED" if coverage_pct > 80 else "✗ PARTIAL" if coverage_pct > 20 else "✗ UNCOVERED"
        print(f"{func_name:30s} | Lines {start:3d}-{end:3d} | {func_covered:3d}/{func_total:3d} ({coverage_pct:5.1f}%) | {status}")

    # Check for uncovered critical lines
    print("\n=== Uncovered Lines in Key Functions ===\n")
    critical_uncovered = []
    for func_name, (start, end) in function_patterns.items():
        func_uncovered = [line for line in range(start, end+1) if line in uncovered_lines]
        if func_uncovered:
            critical_uncovered.append((func_name, func_uncovered))

    if critical_uncovered:
        for func_name, lines in critical_uncovered:
            print(f"{func_name}: Lines {', '.join(map(str, lines))}")
    else:
        print("No critical uncovered lines found!")

    return covered_lines, uncovered_lines, function_patterns

if __name__ == "__main__":
    coverage_file = sys.argv[1] if len(sys.argv) > 1 else "/Users/nelsonpereira/Documents/GitHub/Auditing/Fuzzing/Recon_Fuzzing/Morpho/morpho-blue/echidna/covered.1761655155.txt"
    analyze_morpho_coverage(coverage_file)
