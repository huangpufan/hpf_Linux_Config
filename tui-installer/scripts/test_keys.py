#!/usr/bin/env python3
"""
快速测试按键输入是否正常工作
"""
import sys
import termios
import tty

def test_keyboard():
    """测试键盘输入"""
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    
    try:
        tty.setcbreak(fd)
        print("按键测试（按 q 退出）")
        print("-" * 40)
        
        while True:
            ch = sys.stdin.read(1)
            
            if ch == '\x1b':  # Escape sequence
                seq = sys.stdin.read(2)
                if seq == '[A':
                    print("检测到: UP / k")
                elif seq == '[B':
                    print("检测到: DOWN / j")
                elif seq == '[C':
                    print("检测到: RIGHT / l")
                elif seq == '[D':
                    print("检测到: LEFT / h")
            elif ch in ('q', 'Q'):
                print("退出")
                break
            elif ch == 'j':
                print("检测到: j (向下)")
            elif ch == 'k':
                print("检测到: k (向上)")
            elif ch == 'h':
                print("检测到: h (向左)")
            elif ch == 'l':
                print("检测到: l (向右)")
            elif ch == ' ':
                print("检测到: Space (选择)")
            elif ch in ('\r', '\n'):
                print("检测到: Enter")
            elif ch == 'i':
                print("检测到: i (安装)")
            elif ch == 'a':
                print("检测到: a (批量安装)")
            else:
                print(f"检测到: {repr(ch)}")
    
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)

if __name__ == "__main__":
    test_keyboard()

