clear all;
close all;
clc;

ExperimentsIndex = '05';
NodeIndex = '01';

Str = ['md Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex ];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\PositiveSamples'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\NegativeSamples'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\ResultsOfScanningLAC'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\DetectionResults'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\DetectionResults\NoRemainResults'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\DetectionResults\FalseResults'];
dos(Str);

Str = ['md Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation\PositiveSamples'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation\NegativeSamples'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation\ResultsOfScanningLAC'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation\DetectionResults'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation\DetectionResults\NoRemainResults'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation\DetectionResults\FalseResults'];
dos(Str);