clear all;
close all;
clc;

ExperimentsIndex = '01';
NodeIndex = '01';

Str = ['md Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex ];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Training'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Training\PositiveSamples'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Training\NegativeSamples'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Training\ResultsOfScanningBDA'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Training\DetectionResults'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Training\DetectionResults\FalseResults'];
dos(Str);

Str = ['md Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Validation'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Validation\PositiveSamples'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Validation\NegativeSamples'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Validation\ResultsOfScanningBDA'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Validation\DetectionResults'];
dos(Str);
Str = ['md Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Validation\DetectionResults\FalseResults'];
dos(Str);