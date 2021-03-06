%Exports graph in GraphML format.
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef GMLExporter < synnetgen.extension.Extension
    properties (Constant)
        id = 'gml'
        description = 'GML graph exporter'
        inputs = struct(...
            'filename', 'File name' ...
            )
        outputs = struct (...
            'status', 'Indicates success (True/False)' ...
            )
    end
    
    methods (Static)
        function status = run(graph, varargin)
            %parse arguments
            validateattributes(graph, {'synnetgen.graph.Graph'}, {'scalar'});
            
            ip = inputParser;
            ip.addParameter('filename', []);
            ip.parse(varargin{:});
            filename = ip.Results.filename;
            
            if isempty(graph)
                throw(MException('SynNetGen:InvalidArgument', 'graph must be defined'));
            end
            if isempty(filename)
                throw(MException('SynNetGen:InvalidArgument', 'filename must be defined'));
            end
            
            %export
            fid = fopen(filename, 'w+');
            if fid == -1
                throw(MException('SynNetGen:UnableToOpenFile', 'Unable to open file %s', filename));
            end
            
            fprintf(fid, 'graph [\n');
            fprintf(fid, '\tid "G"\n');
            fprintf(fid, '\tdirected 1\n');
            
            for iNode = 1:numel(graph.nodes)
                fprintf(fid, '\tnode [\n\t\tid "%s"\n\t\tlabel "%s"\n\t]\n', ...
                    strrep(graph.nodes(iNode).id, '"', '\"'), ...
                    strrep(graph.nodes(iNode).label, '"', '\"'));
            end
            
            [iFrom, iTo] = find(graph.edges);
            for iEdge = 1:numel(iFrom)
                if graph.edges(iFrom(iEdge), iTo(iEdge)) == 1
                    sign = '+';
                else
                    sign = '-';
                end
                fprintf(fid, '\tedge [\n\t\tsource "%s"\n\t\ttarget "%s"\n\t\tlabel "%s"\n\t]\n', ...
                    strrep(graph.nodes(iFrom(iEdge)).id, '"', '\"'), ...
                    strrep(graph.nodes(iTo(iEdge)).id, '"', '\"'), ...
                    sign);
            end
            
            fprintf(fid, ']\n');
            
            fclose(fid);
            
            status = true;
        end
    end
end