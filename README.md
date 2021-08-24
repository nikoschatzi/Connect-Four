<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="logo.png" alt="Logo" width="70" height="70">
  </a>
  <h3 align="center">Score4</h3>
</p>



<p align="center">
<img src="https://github.com/nikoschatzi/Score4/blob/main/img.png" align="center" width="705" height="380" />
</p>


<!-- ABOUT THE PROJECT -->
## About The Project
The repository includes the implementation of Score4 game. 
This project was implemented in the VLSI course of the 8th semester of ECE DUTh which was supervised by Associate professor George Dimitrakopoulos.


<!-- GETTING STARTED -->
## Getting Started
To get started make sure you have installed all the prerequisites in your computer and then follow the instuctions in the installation section.

### Prerequisites
To compile this implementation of RSA you will need:
- [cmake](https://cmake.org/download/)
- [boost](https://www.boost.org/users/download/) library, which can also be extracted from the 7z included
  - Make sure to include the path of the library in the CMakeLists
- A compiler that supports std11 and threading
  - (This project was tested with [mingw64](http://mingw-w64.org/doku.php) version 8)

### Installation
To run the example: 
- Open the example folder and type:
```
mkdir build
cd build
cmake ..
make
```
- Add a file named plain.txt with the message you want to encrypt before running the output file.

To run the tests, follow the same procedure.


<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be, learn, inspire, and create.  
Contribute following the above steps:

1. Fork the Project
2. Create your Feature Branch (`git checkout -b new_branch_name`)
3. Commit your Changes (`git commit -m 'Add some extra functionality'`)
4. Push to the Branch (`git push origin new_branch_name`)
5. Open a Pull Request  
