import sys
import numpy as np

out_h = sys.argv[1]
out_mips = sys.argv[2]
size = int(sys.argv[3])

# 2d true/false initial board raw data
data = np.random.choice(a=['0', '1'], size=(size, size), p=[0.5, 0.5])

# export to c header file
with open(out_h, 'w') as f:
    f.write(f'#define NN {size}\n')
    f.write('int N = NN;\n')
    f.write('char board[NN][NN] = {\n')
    for line in data:
        f.write('   {')
        f.write(','.join(line))
        f.write('},\n')
    f.write('};\n')
    f.write('char newboard[NN][NN];\n')
        
# export to mips include file
with open(out_mips, 'w') as f:
    f.write('   .data\n')
    f.write(f'N:	.word {size}\n')
    f.write('board:\n')
    for line in data:
        f.write('   .byte ')
        f.write(', '.join(line))
        f.write('\n')
    f.write(f'newBoard: .space {size * size}')