# SynNetGen
MATLAB toolbox for creating random dynamical models, Boolean networks, and graphs. The toolbox is highly extensible such that additional methods can easily be added to provide additional ways of generating dynamical models from Boolean networks, as well as additional ways to transform all three types of models.

## Installation

### Requirements

Package                                                                    | Tested version | Required for
-------------------------------------------------------------------------- | -------------- | --------------------------
[MATLAB](http://www.mathworks.com/products/matlab)                         | 2014a          | **Core functionality**
[MATLAB-SimBiology Toolbox](http://www.mathworks.com/products/simbiology)  | 2014a          | Export models to SBML
[MATLAB-Symbolic Math Toolbox](http://www.mathworks.com/products/symbolic) | 2014a          | Test equality of ODE models
[GraphViz](http://graphviz.org)                                            | 2.36.0         | Plotting
[libSBML-MATLAB](http://sbml.org/Software/libSBML)                         | 5.11.4         | SBML import/export

### Setup
1. Installed required software
2. Clone repository

    ```Shell
    git clone https://github.com/jonrkarr/SynNetGen.git
    ```
3. Change to /path/to/SynNetGen
4. Open MALTAB
5. Run installer

    ```matlab
    install();
    ```
    
## Getting started

[`example.m`](doc/example.m) illustrates how to use this package:

1. Create a random unsigned, undirected graph
2. Randomize the directions and signs to create a random signed, directed graph
3. Convert the graph to a random Boolean network
4. Convert Boolean network to dynamical ODE models
5. Simulate ODE model
6. Calculate steady state of ODE model
7. Print and plot the graphs, network, and ODE models
8. Export the graphs, network, and ODE models

## Documentation

### Overview

![Package overview](doc/Overview.png?raw=true)

The package provides three model classes: Graph, BoolNet, and Odes to represent graphs, Boolean networks, and orindary differential (ODE) models. Each class provides methods for:
* `setNodesAndEdges`, `setNodesAndRules`, `setNodesAndDifferentials`: Adding and setting node and edges/rules/differentials
* `generate`: Generating random models
* `transform`: Transforming models (e.g. randomize edge signs of a graph)
* `convert`: Converting among all three types of models
* `simulate`: Simulating the model
* `display`, `print`, `plot`: Displaying, printing, plotting
* `import`, `export`: Importing, exporting

See the API docs for more information about each function.

### Generators
Model type | ID                     | Description            | Parameters
---------- | ---------------------- | ---------------------- | ----------
Graph      | barabasi-albert        | Barabasi-Albert        | n, m
Graph      | bollobas-pairing-model | Bollobas Pairing Model | n, k
Graph      | edgar-gilbert          | Edgar-Gilbert          | n, p
Graph      | erdos-reyni            | Erdos-Reyni            | n, m
Graph      | qatts-strogatz         | Watts-Strogatz         | n, p, k

### Transforms
Model type  | ID                  | Transform 
----------- | ------------------- | --------------------
Graph       | RandomizeDirections | Randomize directions
Graph       | RandomizeSigns      | Randomize signs
Graph       | RemoveDirections    | Remove directions
Graph       | RemoveSigns         | Remove signs

### Converters
Model type | ID              | Output
---------- | --------------- | ----------------------------------------------------
Graph      | boolnet         | BoolNet
BoolNet    | graph           | Graph
BoolNet    | grn-ode         | ODE &ndash; Gene regulatory network without proteins
BoolNet    | grn-protein-ode | ODE &ndash; Gene regulatory network with proteins
BoolNet    | simbiology      | SimBiology model
Odes       | graph           | Graph
Odes       | simbiology      | SimBiology model

#### Gene regulatory network without proteins (grn-ode)
The grn-ode converter interprets each Boolean network node as a gene and creates dynamical models of transcription similar to SynTReN<sup>1</sup>. grn-ode creates ODE models with variables *r<sub>i</sub>* which represent the instantaneous concentration of the  RNA species of each gene. The differential changes in mRNA concentrations are given by

![grn-ode equation](doc/grn-ode-equation.png?raw=true)
<!--
\frac{dr_i}{dt} &= V^r_i f_i(p) - \frac{\ln{2}}{\tau^r_i} r_i
-->

where
 *V<sup>r</sup><sub>i</sub>* is maximum transcription rate of gene *i*, 
 *&tau;<sup>r</sup><sub>i</sub>* is the half-life of RNA *i*, and
 *f<sub>i</sub>(r)* is a Michaelis-Menten-like function with 2<sup>*K<sub>i</sub>*</sup>-1 rate constants V<sub>*i,k*</sub> where *K<sub>i</sub>* is the number of regulators of gene *i*.

#### Gene regulatory network with proteins (grn-protein-ode)
The grn-protein-ode converter interprets each Boolean network node as a gene and creates dynamical models of transcription and translation similar to GeneNetWeaver<sup>2</sup>. grn-protein-ode creates ODE models with variables *r<sub>i</sub>* which represent the instantaneous concentration of the RNA species of each gene and *p<sub>i</sub>* which represent the instantaneous concentration of the protein species of each gene. The differential changes in mRNA and protein concentrations are given by

![grn-protein-ode equation](doc/grn-protein-ode-equation.png?raw=true)
<!--
\frac{dr_i}{dt} &= v^r_i f_i(p) - \frac{\ln{2}}{\tau^r_i} r_i \\
\frac{dp_i}{dt} &= v^p_i r_i - \frac{\ln{2}}{\tau^p_i} p_i
-->

where
 *V<sup>r</sup><sub>i</sub>* is maximum transcription rate of gene *i*, 
 *V<sup>p</sup><sub>i</sub>* is maximum translation rate of gene *i*, 
 *&tau;<sup>r</sup><sub>i</sub>* is the half-life of RNA *i*, and
 *&tau;<sup>p</sup><sub>i</sub>* is the half-life of protein *i*, and
 *f<sub>i</sub>(p)* is a Michaelis-Menten-like function with 2<sup>*K<sub>i</sub>*</sup>-1 rate constants V<sub>*i,k*</sub> where *K<sub>i</sub>* is the number of regulators of gene *i*.

### File formats
Format    | Extension | ID        | Graph    | BoolNet  | ODEs     | Import   | Export
-------   | --------- | --------- | :------: | :------: | :------: | :------: | :------:
Dot       | dot       | dot       | &#x2713; |          |          |          | &#x2713;
GML       | gml       | gml       | &#x2713; |          |          |          | &#x2713; 
GraphML   | xml       | graphml   | &#x2713; |          |          |          | &#x2713;
MATLAB    | m         | matlab    |          | &#x2713; | &#x2713; |          | &#x2713;
R BoolNet | bn        | r-boolnet |          | &#x2713; |          | &#x2713; | &#x2713;
SBML      | xml       | sbml      |          | &#x2713; | &#x2713; | &#x2713; | &#x2713;
TGF       | tgf       | tgf       | &#x2713; |          |          | &#x2713; | &#x2713;

After the package is installed example files will be located in `doc/example`.

Note: Boolean networks exported to SBML have "NOT" operators replaced with "-" because SimBiology doesn't support NOT.

### API docs
After installing the toolbox, open `/path/to/SynNetGen/doc/m2html/index.html` in your web browser to view the API docs.

## About SynNetGen

### Development team
SynNetGen was developed at the [Icahn School of Medicine at Mount Sinai](http://mssm.edu) by:
* [Jonathan Karr](http://research.mssm.edu/karr)
* [Rui Chang](http://research.mssm.edu/changlab)

### Third party software included in release
* [graphviz4matlab](https://github.com/graphviz4matlab/graphviz4matlab): revision 8cbc3eaa757b2fdcb10fc10af87ee7bd8ea1d6f2
* [M2HTML](http://www.artefact.tk/software/matlab/m2html): version 1.5
* [RBN Toolbox](http://www.teuscher-research.ch/rbntoolbox): version 2.0

### License
SynNetGen is licensed under The MIT License. See [license](LICENSE) for further information.

### Questions? Comments?
Please contact the development team.

## References
1. Van den Bulcke T, Van Leemput K, Naudts B, van Remortel P, Ma H, Verschoren A, De Moor B, Marchal K. SynTReN: a generator of synthetic gene expression data for design and analysis of structure learning algorithms. *BMC Bioinformatics* 2006, 7:43. [PubMed](http://www.ncbi.nlm.nih.gov/pubmed/16438721)
2. Schaffter T, Marbach D, Floreano D. GeneNetWeaver: in silico benchmark generation and performance profiling of network inference methods. *Bioinformatics* 2011, 27(**16**):2263-70. [PubMed](http://www.ncbi.nlm.nih.gov/pubmed/21697125)
