# WHAT IS THIS?
This is the final and relative _"basic"_ proyect for
a universitie class about assembly programing.  
This is a project that works only if you have:
- GDB
- Any c compiler (we used gcc)
- NASM  
  
It works on emulated architecture i386 x86.  
Atleas is tested on Ubuntu and ArchLinux.  
  
You can use this code for your personal use, but
please at least mention one of the colaborators on
this project.
  
Colaborators:  
[Andrew](https://github.com/Andrew869)  
[Eriarer (me)](https://github.com/Eriarer)  
[Gerardo](https://github.com/diosescalera)  
[Leonardo](https://github.com/Laxlev)  
[Mariana](https://github.com/mariana-avila-rivera)  
  
---
# HOT TO COMPILE
If you are using VSCode you can use a task we programmed  
to run easaly the code, with the help of a simple extension  
called [Tasks](https://marketplace.visualstudio.com/items?itemName=actboy168.tasks) it will apear a simple button a the end of your  
screen it is called "create nasm", you can click it and it will run.  
  
If you dont use VSCode you cant run it following the next commands:
- cd ${fileDirname} 
- nasm -f elf32 ${fileBasename} -g -F dwarf
- gcc -m32 ${fileBasenameNoExtension}.o printAnswer.c -o ${fileBasenameNoExtension} -no-pie 
- ./${fileBasenameNoExtension}  
  
Or just simply go to the .asm file directory  
and excecute the next commands:
- nasm -f elf32 NPI.asm -g -G dwarf
- gcc -m32 NPI.o printAnswer.c -o NPI -no-pie
- ./NPI
  
That's all, thank you :D





