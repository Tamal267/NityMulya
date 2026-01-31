from pylatex import Document
import subprocess
import os

tex_file = 'thesis_paper.tex'
pdf_file = 'thesis_paper.pdf'

# Compile LaTeX to PDF using pdflatex if available
try:
    subprocess.run(['pdflatex', tex_file], check=True)
    print('PDF generated using pdflatex!')
except Exception as e:
    print('pdflatex not found or failed:', e)
    # Try using MiKTeX if available
    miktex_path = r'C:\Program Files\MiKTeX\miktex\bin\x64\pdflatex.exe'
    if os.path.exists(miktex_path):
        try:
            subprocess.run([miktex_path, tex_file], check=True)
            print('PDF generated using MiKTeX pdflatex!')
        except Exception as e2:
            print('MiKTeX pdflatex failed:', e2)
    else:
        print('No pdflatex found. Please install a LaTeX distribution.')
