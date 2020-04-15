# The VNS
## Prerequisites 
1. Compile and install the [ARGoS simulator](https://github.com/ilpincy/argos3)
2. Compile and install the [SRoCS plugin for the ARGoS simulator](https://github.com/allsey87/argos3-srocs)
3. Compile the [VNS Loop Function and User function](https://github.com/allsey87/argos3-vns2)

## Usage
### Running an example
`argos3 -c testing/Allocate/vns.argos`

It maynot work, before running this command, you may need to check the loopfunction directory and user function directory in testing/Allocate/vns.argos . 
In this example, they are in line 54 and line 177 of testing/Allocate/vns.argos. Make sure that directories is pointing to the place you compile VNS Loop Function and usr functions (step 3 in the Prerequisites).

Again, run
`argos3 -c testing/Allocate/vns.argos`

You should be able to see drones and pipucks form a formation.
