def compare_files(file_paths):
    """
    Compares multiple files line by line and prints differences.

    Args:
        file_paths: A list of file paths to compare.
    """
    numfiles = len(file_paths)
    if not file_paths or numfiles < 2:
        print("Please provide at least two file paths for comparison.")
        return

    try:
        files = [open(file_path, 'r') for file_path in file_paths]
        lines = [file.readlines() for file in files]

        max_lines = max(len(line_list) for line_list in lines)

        if print_intel:
            print("Intel format hex");
        elif numfiles == 2:
            print(f"Addr: smallest ; file1 file2 Y/N/E (did value grow?)")
        elif numfiles == 3:
            print(f"Addr: smallest ; file1 file2 file3 Y/N/E (did value grow?)")
        elif numfiles == 6:
            print(f"Addr: smallest ; file1 file2 file3 file4 file5 file6 Y/N/E (did value grow?)")

        for i in range(max_lines):
            diff = False
            line_values = []

            for j, line_list in enumerate(lines):
                lineaddr = line_list[i].split(": ")

                if i < len(line_list):
                    line = line_list[i].rstrip('\n')
                else:
                    line = ''
                line_values.append(line)

            if len(set(line_values)) > 1:
                diff = True

            if diff:
                myline = []
                myline.append(lineaddr[0])
                bigger = []
                #smallest = ''
                # on first iteration find the smallest value
                for k, file_path in enumerate(file_paths):
                    line_vals=line_values[k].split(" ")
                    cur_val = line_vals[1]
                    if k == 0:
                        smallest = cur_val
                    else:
                        if cur_val < smallest:
                            smallest = cur_val

                # second time through compare values to the smallest found
                for k, file_path in enumerate(file_paths):
                    line_vals=line_values[k].split(" ")
                    cur_val = line_vals[1]
                    myline.append(cur_val)
                    if cur_val == smallest:
                        bigger.append('E')	# current value even to smallest
                    elif cur_val < smallest:
                        bigger.append('N')	# current value smaller than smallest this should not happen on second run since we've found smallest value previously so now can only be even or bigger.
                    else:
                        bigger.append('Y')	# current value bigger than smallest

                if print_intel:
                    chksum = hex(256 - (( 1 + ( int(myline[0],16) // 256 ) + ( int(myline[0],16) % 256 ) + int(smallest,16) ) % 256 ))[2:]
                    #print(f"{myline[0]}: {smallest} ; {myline[1]} {myline[2]} , {bigger[0]} {bigger[1]}")
                    print(f":01{myline[0][4:]}00{smallest}{chksum.zfill(2)}")
                elif numfiles == 2:
                    print(f"{myline[0]}: {smallest} ; {myline[1]} {myline[2]} , {bigger[0]} {bigger[1]}")
                elif numfiles == 3:
                    print(f"{myline[0]}: {smallest} ; {myline[1]} {myline[2]} {myline[3]} , {bigger[0]} {bigger[1]} {bigger[2]}")
                elif numfiles == 6:
                    print(f"{myline[0]}: {smallest} ; {myline[1]} {myline[2]} {myline[3]} {myline[4]} {myline[5]} {myline[6]} , {bigger[0]} {bigger[1]} {bigger[2]} {bigger[3]} {bigger[4]} {bigger[5]}")

            elif print_good:
                if print_intel:
                    line_vals=line_values[0].split(" ")
                    chksum = hex(256 - (( 1 + ( int(lineaddr[0],16) // 256 ) + ( int(lineaddr[0],16) % 256 ) + int(line_vals[1],16) ) % 256 ))[2:]
                    print(f":01{lineaddr[0][4:]}00{line_vals[1]}{chksum.zfill(2)}")
                else:
                    line_vals=line_values[0].split(" ")
                    print(f"{lineaddr[0]}: {line_vals[1]}")

    except FileNotFoundError as e:
        print(f"Error: File not found: {e.filename}")
    finally:
      for file in files:
          file.close()

file_paths = ["reverse_eng/d5_lo.hex", "reverse_eng/d5_hi.hex"]
#file_paths = ["reverse_eng/d5_lo.hex", "reverse_eng/d5_label_2024_lo.hex", "reverse_eng/d5_label_2025_lo.hex"]
#file_paths = ["reverse_eng/d5_hi.hex", "reverse_eng/d5_label_2024_hi.hex", "reverse_eng/d5_label_2025_hi.hex"]
#file_paths = ["reverse_eng/d5_lo.hex", "reverse_eng/d5_hi.hex", "reverse_eng/d5_label_2024_lo.hex", "reverse_eng/d5_label_2024_hi.hex", "reverse_eng/d5_label_2025_lo.hex", "reverse_eng/d5_label_2025_hi.hex"]
"""
# Create sample files (optional - for testing)
with open("file1.txt", "w") as f:
    f.write("Line 1\nLine 2\nLine 3\nL4\nL5\n6")
with open("file2.txt", "w") as f:
    f.write("Line 1\nDifferent line\nLine 3\nL4\n5\nL6")
with open("file3.txt", "w") as f:
    f.write("Line 1\nLine 2\nAnother line\n4\n5\n6")
"""

# also include bytes that have not changed? 
print_good = True
# output in Intel Hex format?
print_intel = True

compare_files(file_paths)
