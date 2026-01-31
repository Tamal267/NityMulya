#!/usr/bin/env python3
"""
PDF Generator for Thesis Paper
This script compiles a LaTeX thesis paper into a PDF document.
"""

import subprocess
import os
import sys

def generate_pdf():
    """Generate PDF from LaTeX thesis file"""
    
    # Get the directory where this script is located
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Define the LaTeX file
    tex_file = "thesis_paper.tex"
    tex_path = os.path.join(script_dir, tex_file)
    
    # Check if the LaTeX file exists
    if not os.path.exists(tex_path):
        print(f"Error: {tex_file} not found in {script_dir}")
        return False
    
    print(f"Found LaTeX file: {tex_path}")
    print("Compiling LaTeX to PDF...")
    print("-" * 50)
    
    # Change to the directory containing the tex file
    os.chdir(script_dir)
    
    try:
        # Run pdflatex twice to resolve references
        # First pass
        print("\nFirst compilation pass...")
        result1 = subprocess.run(
            ["pdflatex", "-interaction=nonstopmode", tex_file],
            capture_output=True,
            text=True,
            timeout=60
        )
        
        if result1.returncode != 0:
            print("Warning: First pass completed with errors")
            print(result1.stdout[-500:] if len(result1.stdout) > 500 else result1.stdout)
        else:
            print("First pass completed successfully")
        
        # Second pass to resolve citations and references
        print("\nSecond compilation pass...")
        result2 = subprocess.run(
            ["pdflatex", "-interaction=nonstopmode", tex_file],
            capture_output=True,
            text=True,
            timeout=60
        )
        
        if result2.returncode != 0:
            print("Warning: Second pass completed with errors")
            print(result2.stdout[-500:] if len(result2.stdout) > 500 else result2.stdout)
        else:
            print("Second pass completed successfully")
        
        # Check if PDF was created
        pdf_file = tex_file.replace(".tex", ".pdf")
        pdf_path = os.path.join(script_dir, pdf_file)
        
        if os.path.exists(pdf_path):
            file_size = os.path.getsize(pdf_path) / 1024  # Size in KB
            print("-" * 50)
            print(f"✓ SUCCESS! PDF generated: {pdf_file}")
            print(f"  Location: {pdf_path}")
            print(f"  Size: {file_size:.2f} KB")
            print("-" * 50)
            
            # Clean up auxiliary files
            cleanup_extensions = ['.aux', '.log', '.out']
            print("\nCleaning up auxiliary files...")
            for ext in cleanup_extensions:
                aux_file = tex_file.replace(".tex", ext)
                aux_path = os.path.join(script_dir, aux_file)
                if os.path.exists(aux_path):
                    os.remove(aux_path)
                    print(f"  Removed: {aux_file}")
            
            return True
        else:
            print("-" * 50)
            print("✗ ERROR: PDF was not generated")
            print("Check the LaTeX compilation errors above")
            print("-" * 50)
            return False
            
    except subprocess.TimeoutExpired:
        print("Error: LaTeX compilation timed out")
        return False
    except FileNotFoundError:
        print("Error: pdflatex command not found")
        print("\nTo install LaTeX on Ubuntu/Debian:")
        print("  sudo apt-get update")
        print("  sudo apt-get install texlive-latex-base texlive-latex-extra")
        print("\nTo install LaTeX on Fedora/RHEL:")
        print("  sudo dnf install texlive-scheme-basic")
        print("\nTo install LaTeX on Arch Linux:")
        print("  sudo pacman -S texlive-core")
        return False
    except Exception as e:
        print(f"Error: An unexpected error occurred: {e}")
        return False

if __name__ == "__main__":
    print("=" * 50)
    print("  THESIS PAPER PDF GENERATOR")
    print("=" * 50)
    print()
    
    success = generate_pdf()
    
    if success:
        print("\n✓ PDF generation completed successfully!")
        sys.exit(0)
    else:
        print("\n✗ PDF generation failed")
        sys.exit(1)
