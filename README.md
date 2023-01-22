# Code for Ben-Eater based 65c02 Computer Projects

## Description
I write code for my 65c02 project, all of the code files are dumped here

## Building
The projects are built using [vasm](https://www.youtube.com/watch?v=dQw4w9WgXcQ) (assembler), [vlink](https://www.youtube.com/watch?v=dQw4w9WgXcQ) (linker), and [vbcc](https://www.youtube.com/watch?v=dQw4w9WgXcQ) (C compiler).
```
*.s  ------------->   ---vasm---> .vobj ---vlink---> .bin (32kb ROM image)
                    ^                   ^
*.c  ----vbcc----->.s            link.ld
```
