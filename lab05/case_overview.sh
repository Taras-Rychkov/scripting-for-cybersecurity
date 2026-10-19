#!/bin/bash
echo "Directories in the collection:"
find case -type d
echo ""
echo "Size of the collection:"
du -sh case
echo "Done."
echo "Regular files:"
find case -type f | wc -l
echo ""
echo "Log files:"
ls case/logs
echo ""
