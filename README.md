# Ada BMP Library

[![Build Status](https://travis-ci.org/ellamosi/Ada_BMP_Library.svg?branch=master)](https://travis-ci.org/ellamosi/Ada_BMP_Library)

This project aims to provide very basic bitmap image manipulation features 
and BMP file I/O to Ada programs. It's based on the bitmap handling capabilities
of the [Ada Drivers Library](https://github.com/AdaCore/Ada_Drivers_Library) project.

## Features
- Versatile buffer representation of bitmaps
- BMP file reading (very limited support for now)
- BMP file writing
- Drawing primitives include
  - Variable thickness lines
  - Rectangle fill/outline
  - Rounded rectangle fill/outline
  - Circle fill/outline
  - Bezier curves

## Getting started

### Prerequisites

The software is written in Ada 2012 and can be used with a compiler like 
"GNAT GPL 2017" [(Download it here)](http://libre.adacore.com/download/configurations).

### Project setup

Clone the project into a directory of your choice. Add the dependency to your
project, if you use a GPR based tool, just reference the bitmap project file 
like so:

```
with "../Ada_BMP_Library/bitmap";
```

### Usage

To start using the Ada_Drivers_Library, please check out the tests, which 
illustrate file I/O, buffer allocation and bitmap manipulation.

- [File input test](testsuite/tests/bmp_file_input/src/tc_bmp_file_input.adb):
Showcases BMP file reading and bitmap manipulation
- [File output test](testsuite/tests/bmp_file_output/src/tc_bmp_file_output.adb):
Showcases bitmap manipulation and BMP file writing

## License

All files are provided under a 3-clause Berkeley Software Distribution (BSD)
license. As such, and within the conditions required by the license, the files
are available both for proprietary ("commercial") and non-proprietary use.

For details, see the `LICENSE` file in the root directory.

