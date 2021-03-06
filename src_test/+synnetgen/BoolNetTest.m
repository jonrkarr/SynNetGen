%Tests boolean network class and associated extensions
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef BoolNetTest < matlab.unittest.TestCase
    methods (Test)
        function testNewNetwork(this)
            n = synnetgen.boolnet.BoolNet();
        end
        
        function testAddNode(this)
            n = synnetgen.boolnet.BoolNet();
            
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'C');
            
            this.verifyEqual(n.rules, {''; ''; ''});
        end
        
        function testSetRule(this)
            n = synnetgen.boolnet.BoolNet();
            
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'C');
            n.setRule('b', 'a');
            this.verifyEqual(n.rules, {''; 'a'; ''});
        end
        
        function testAreRulesValid(this)
            n = synnetgen.boolnet.BoolNet();
            
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'C');
            
            this.verifyTrue(n.areRulesValid(n.nodes, {'a'}));
            this.verifyTrue(n.areRulesValid(n.nodes, {'a || b'}));
            this.verifyTrue(n.areRulesValid(n.nodes, {'((a || (b)))'}));
            this.verifyFalse(n.areRulesValid(n.nodes, {'A'}));
            this.verifyFalse(n.areRulesValid(n.nodes, {'d'}));
        end
        
        function testSetNodesAndRules(this)
            n = synnetgen.boolnet.BoolNet();
            
            nodes = [
                struct('id', 'a', 'label', 'A')
                struct('id', 'b', 'label', 'B')
                struct('id', 'c', 'label', 'C')
                ];
            rules = {'b || c'; 'a && c'; '~a && b'};
            n.setNodesAndRules(nodes, rules);
            
            this.verifyEqual(n.nodes, nodes);
            this.verifyEqual(n.rules, rules);
        end
        
        function testSetRules(this)
            n = synnetgen.boolnet.BoolNet();
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'C');
            
            rules = {'b || c'; 'a && c'; '~a && b'};
            n.setRules(rules);
            
            this.verifyEqual(n.rules, rules);
        end
        
        function testGetTruthTables(this)
            n = synnetgen.boolnet.BoolNet();
            
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'C');
            n.setRule('a', 'b || c');
            n.setRule('b', 'c && a');
            n.setRule('c', '~(a || b) && c');
            
            truthTables = n.getTruthTables();
            this.verifySize(truthTables, [3 8]);
            this.verifyEqual(sum(~isnan(truthTables), 2), [4 4 8]');
            this.verifyEqual(nansum(truthTables, 2), [3; 1; 1]);
            this.verifyEqual(truthTables, [
                0 1 1 1 NaN NaN NaN NaN
                0 0 0 1 NaN NaN NaN NaN
                0 1 0 0 0   0   0   0
                ]);
        end
        
        function testGetTruthTablesSimplified(this)
            n = synnetgen.boolnet.BoolNet();
            
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'C');
            n.setRule('a', 'b || c');
            n.setRule('b', 'a || ~a');
            n.setRule('c', '~(a || b) && c');
            
            truthTables = n.getTruthTables('simplify', true);
            this.verifySize(truthTables, [3 8]);
            this.verifyEqual(sum(~isnan(truthTables), 2), [4 0 8]');
            this.verifyEqual(nansum(truthTables, 2), [3; 0; 1]);
            this.verifyEqual(truthTables, [
                0   1   1   1   NaN NaN NaN NaN
                NaN NaN NaN NaN NaN NaN NaN NaN
                0   1   0   0   0   0   0   0
                ]);
        end
        
        function testGetEdges(this)
            %ex 1
            n = synnetgen.boolnet.BoolNet();
            
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'C');
            n.setRule('a', 'b || c');
            n.setRule('b', 'c && a');
            n.setRule('c', '~(a || b) && c');
            
            edges = n.getEdges();
            this.verifyEqual(edges, [
                0 1 -1
                1 0 -1
                1 1  1
                ]);
            
            %ex 2
            n = synnetgen.boolnet.BoolNet();
            
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'C');
            n.setRule('a', 'b || c');
            n.setRule('b', 'a || ~a');
            n.setRule('c', '~(a || b) && c');
            
            edges = n.getEdges();
            this.verifyEqual(edges, [
                0 0 -1
                1 0 -1
                1 0 1
                ]);
            
            %ex 3
            n = synnetgen.boolnet.BoolNet();
            
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'C');
            n.addNode('d', 'D');
            n.addNode('e', 'E');
            n.addNode('f', 'F');
            n.setRule('a', '~(a || b || c) && (d || e || f)');
            n.setRule('b', '~d && (a || b)');
            n.setRule('c', '(c || b)');
            n.setRule('d', '~(c || b)');
            n.setRule('e', '~(a && b) && (c || d)');
            n.setRule('f', '~(a && b) && (a && c)');
            
            edges = n.getEdges();
            this.verifyEqual(edges, [
                -1  1  0  0 -1 NaN
                -1  1  1 -1 -1  -1
                -1  0  1 -1  1   1
                1 -1  0  0  1   0
                1  0  0  0  0   0
                1  0  0  0  0   0
                ]);
        end
        
        function testSimulate(this)
            n = synnetgen.boolnet.BoolNet();
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'C');
            n.setRule('a', '~c');
            n.setRule('b', '~a');
            n.setRule('c', 'b');
            
            tMax = 10;
            y0 = [0; 0; 0];
            vals = n.simulate('tMax', tMax, 'y0', y0);
            this.verifySize(vals, [numel(n.nodes) tMax + 1]);
            this.verifyEqual(vals(:, 1:3:end), repmat(y0, 1, 4))
            this.verifyEqual(vals(:, 2:3:end), repmat([1; 1; 0], 1, 4))
            this.verifyEqual(vals(:, 3:3:end), repmat([1; 0; 1], 1, 3))
        end
        
        function testIsequal(this)
            n = synnetgen.boolnet.BoolNet();
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'C');
            n.setRule('a', 'b');
            n.setRule('b', 'c && a');
            n.setRule('c', 'a');
            
            m = synnetgen.boolnet.BoolNet();
            m.addNode('b', 'B');
            m.addNode('a', 'A');
            m.addNode('c', 'C');
            m.setRule('a', 'b');
            m.setRule('b', '~(~a || ~c)');
            m.setRule('c', 'a');
            this.verifyEqual(n, m);
            
            o = synnetgen.boolnet.BoolNet();
            o.addNode('b', 'B');
            o.addNode('a', 'A');
            o.addNode('c', 'C');
            o.addNode('d', 'D');
            o.setRule('a', 'b');
            o.setRule('b', '~(~a || ~c)');
            o.setRule('c', 'a');
            this.verifyNotEqual(o, m);
            
            p = synnetgen.boolnet.BoolNet();
            p.addNode('b', 'B');
            p.addNode('a', 'A');
            p.addNode('c', 'C');
            p.setRule('a', 'b');
            p.setRule('b', '~(a || ~c)');
            p.setRule('c', 'a');
            this.verifyNotEqual(p, m);
        end
        
        function testClear(this)
            n = synnetgen.boolnet.BoolNet();
            
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'C');
            n.setRule('a', 'b');
            n.setRule('b', 'c');
            n.setRule('c', 'a');
            n.clear();
            
            this.verifyEqual(n.nodes, repmat(struct('id', '', 'label', ''), 0, 1));
            this.verifyEqual(n.rules, cell(0, 1));
        end
        
        function testCopy(this)
            n = synnetgen.boolnet.BoolNet();
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'C');
            n.setRule('a', 'b');
            n.setRule('b', 'c');
            n.setRule('c', 'a');
            
            m = n.copy();
            
            this.verifyEqual(m.nodes, n.nodes);
            this.verifyEqual(m.rules, n.rules);
        end
        
        function testDisp(this)
            n = synnetgen.boolnet.BoolNet();
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'C');
            n.setRule('a', 'b');
            n.setRule('b', 'c');
            n.setRule('c', 'a');
            
            n
        end
        
        function testPrint(this)
            n = synnetgen.boolnet.BoolNet();
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'C');
            n.setRule('a', 'b');
            n.setRule('b', 'c');
            n.setRule('c', 'a');
            
            this.verifyTrue(iscell(n.print()))
            this.verifyTrue(all(cellfun(@ischar, n.print())));
        end
        
        function testPlot(this)
            n = synnetgen.boolnet.BoolNet();
            
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'C');
            n.addNode('d', 'D');
            n.addNode('e', 'E');
            n.addNode('f', 'F');
            n.setRule('a', '~(a || b || c) && (d || e || f)');
            n.setRule('b', '~d && (a || b)');
            n.setRule('c', '(c || b)');
            n.setRule('d', '~(c || b)');
            n.setRule('e', '~(a && b) && (c || d)');
            n.setRule('f', '~(a && b) && (a && c)');
            
            h = n.plot();
            close(h);
        end
        
        function testConvertToFromGraph(this)
            n = synnetgen.boolnet.BoolNet();
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'C');
            n.addNode('d', 'D');
            n.addNode('e', 'E');
            n.addNode('f', 'F');
            n.setRule('a', '~(a || b || c) && (d || e || f)');
            n.setRule('b', '~d && (a || b)');
            n.setRule('c', '(c || b)');
            n.setRule('d', '~(c || b)');
            n.setRule('e', '~(d && e) && (c && d)');
            n.setRule('f', '~(f || e) && (a || c)');
            
            g = n.convert('graph');
            m = g.convert('boolnet');
            this.verifyEqual(m, n);
        end
        
        function testConvertToGrnOdes(this)
            %% Ex 1
            n = synnetgen.boolnet.BoolNet();
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.setRule('a', 'a');
            n.setRule('b', 'a || b');
            
            autoM = n.convert('grn-ode');
            
            m = synnetgen.odes.Odes();
            m.addNode('r_a', 'RNA a');
            m.addNode('r_b', 'RNA b');
            
            m.addParameter('V_max_r_a', 'Maximum transcription rate of gene a');
            m.addParameter('V_rel_on_r_a', 'Relative transcription rate of gene a when enhanced [0-1]');
            m.addParameter('V_rel_off_r_a', 'Releative transcription rate of gene a when repressed [0-1]');
            m.addParameter('K_r_a', 'Transcription factor binding site affinity of protein a');
            m.addParameter('n_r_a', 'Hill coefficient of gene a');
            m.addParameter('tau_r_a', 'Half-life of RNA a');
            
            m.addParameter('V_max_r_b', 'Maximum transcription rate of gene b');
            m.addParameter('V_rel_on_r_b', 'Relative transcription rate of gene b when enhanced [0-1]');
            m.addParameter('V_rel_off_r_b', 'Releative transcription rate of gene b when repressed [0-1]');
            m.addParameter('K_r_b', 'Transcription factor binding site affinity of protein b');
            m.addParameter('n_r_b', 'Hill coefficient of gene b');
            m.addParameter('tau_r_b', 'Half-life of RNA b');
            
            m.setDifferential('r_a', 'V_max_r_a * (V_rel_off_r_a + V_rel_on_r_a * (r_a/K_r_a)^n_r_a)/(1 + (r_a/K_r_a)^n_r_a) - 0.6931/tau_r_a * r_a');
            m.setDifferential('r_b', 'V_max_r_b * (V_rel_off_r_b + V_rel_on_r_b * (r_a/K_r_a)^n_r_a + V_rel_on_r_b * (r_b/K_r_b)^n_r_b + V_rel_on_r_b * (r_a/K_r_a)^n_r_a * (r_b/K_r_b)^n_r_b)/(1 + (r_a/K_r_a)^n_r_a + (r_b/K_r_b)^n_r_b + (r_a/K_r_a)^n_r_a * (r_b/K_r_b)^n_r_b) - 0.6931/tau_r_b * r_b');
            
            this.verifyEqual(autoM, m);
            
            %% Ex 2
            n = synnetgen.boolnet.BoolNet();
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'B');
            n.setRule('a', 'c');
            n.setRule('b', 'a');
            n.setRule('c', 'b');
            
            m = n.convert('grn-ode');
            %n.plot();
            
            y = [0; 0; 0];
            k = [1; 1; 0.1; 1; 1; 1; 1; 1; 0.1; 1; 1; 1; 1; 1; 0.1; 1; 1; 1;];
            %m.plot('y', y, 'k', k);
            
            this.verifyEqual(m.getEdges('y', y, 'k', k), n.getEdges() - eye(3));
            
            %% Ex 3
            n = synnetgen.boolnet.BoolNet();
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'C');
            n.addNode('d', 'D');
            n.setRule('a', 'a');
            n.setRule('b', 'b');
            n.setRule('c', 'a || b');
            n.setRule('d', 'c && d');
            
            m = n.convert('grn-ode');
            this.verifyClass(m, 'synnetgen.odes.Odes');
        end
        
        function testConvertToGrnProteinOdes(this)
            %% Ex 1
            n = synnetgen.boolnet.BoolNet();
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.setRule('a', 'a');
            n.setRule('b', 'a || b');
            
            autoM = n.convert('grn-protein-ode');
            
            m = synnetgen.odes.Odes();
            m.addNode('r_a', 'RNA a');
            m.addNode('r_b', 'RNA b');
            m.addNode('p_a', 'Protein a');
            m.addNode('p_b', 'Protein b');
            
            m.addParameter('V_max_r_a', 'Maximum transcription rate of gene a');
            m.addParameter('V_rel_on_r_a', 'Relative transcription rate of gene a when enhanced [0-1]');
            m.addParameter('V_rel_off_r_a', 'Releative transcription rate of gene a when repressed [0-1]');
            m.addParameter('K_r_a', 'Transcription factor binding site affinity of protein a');
            m.addParameter('n_r_a', 'Hill coefficient of gene a');
            m.addParameter('tau_r_a', 'Half-life of RNA a');
            m.addParameter('V_max_p_a', 'Maximum translation rate of gene a');
            m.addParameter('tau_p_a', 'Half-life of protein a');
            
            m.addParameter('V_max_r_b', 'Maximum transcription rate of gene b');
            m.addParameter('V_rel_on_r_b', 'Relative transcription rate of gene b when enhanced [0-1]');
            m.addParameter('V_rel_off_r_b', 'Releative transcription rate of gene b when repressed [0-1]');
            m.addParameter('K_r_b', 'Transcription factor binding site affinity of protein b');
            m.addParameter('n_r_b', 'Hill coefficient of gene b');
            m.addParameter('tau_r_b', 'Half-life of RNA b');
            m.addParameter('V_max_p_b', 'Maximum translation rate of gene b');
            m.addParameter('tau_p_b', 'Half-life of protein b');
            
            m.setDifferential('r_a', 'V_max_r_a * (V_rel_off_r_a + V_rel_on_r_a * (p_a/K_r_a)^n_r_a)/(1 + (p_a/K_r_a)^n_r_a) - 0.6931/tau_r_a * r_a');
            m.setDifferential('r_b', 'V_max_r_b * (V_rel_off_r_b + V_rel_on_r_b * (p_a/K_r_a)^n_r_a + V_rel_on_r_b * (p_b/K_r_b)^n_r_b + V_rel_on_r_b * (p_a/K_r_a)^n_r_a * (p_b/K_r_b)^n_r_b)/(1 + (p_a/K_r_a)^n_r_a + (p_b/K_r_b)^n_r_b + (p_a/K_r_a)^n_r_a * (p_b/K_r_b)^n_r_b) - 0.6931/tau_r_b * r_b');
            m.setDifferential('p_a', 'V_max_p_a * r_a - 0.6931/tau_p_a * p_a');
            m.setDifferential('p_b', 'V_max_p_b * r_b - 0.6931/tau_p_b * p_b');
            
            this.verifyEqual(autoM, m);
            
            %% Ex 2
            n = synnetgen.boolnet.BoolNet();
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'C');
            n.addNode('d', 'D');
            n.setRule('a', 'a');
            n.setRule('b', 'b');
            n.setRule('c', 'a || b');
            n.setRule('d', 'c && d');
            
            m = n.convert('grn-protein-ode');
            this.verifyClass(m, 'synnetgen.odes.Odes');
        end
        
        function testRBoolNetExportImport(this)
            n = synnetgen.boolnet.BoolNet();
            n.addNode('a', 'a');
            n.addNode('b', 'b');
            n.addNode('c', 'c');
            n.addNode('d', 'd');
            n.addNode('e', 'e');
            n.addNode('f', 'f');
            n.setRule('a', '~(a || b || c) && (d || e || f)');
            n.setRule('b', '~d && (a || b)');
            n.setRule('c', '(c || b)');
            n.setRule('d', '~(c || b)');
            n.setRule('e', '~(d && e) && (c && d)');
            n.setRule('f', '~(f || e) && (a || c)');
            
            filename = tempname();            
            n.export('R-BoolNet', 'filename', filename);
            m = synnetgen.boolnet.BoolNet();
            m = m.import('R-BoolNet', 'filename', filename);
            delete(filename);
            
            this.verifyEqual(m, n);
        end
        
        function testMATLABExport(this)
            n = synnetgen.boolnet.BoolNet();
            n.addNode('a', 'A');
            n.addNode('b', 'B');
            n.addNode('c', 'B');
            n.setRule('a', '~c');
            n.setRule('b', '~a');
            n.setRule('c', 'b');
            
            filename = [tempname('.') '.m'];
            funcName = filename(3:end-2);
            n.export('MATLAB', 'filename', filename);
            
            rehash();
            func = str2func(funcName);
            this.verifyTrue(isa(func, 'function_handle'));
            
            y0 = false(3, 1);
            y1 = feval(func, 0, y0);
            this.verifyEqual(y1, [true; true; false]);
            
            delete(filename);
        end
        
        function testSBMLExportAndImport(this)
            n = synnetgen.boolnet.BoolNet();
            n.addNode('a', 'a');
            n.addNode('b', 'b');
            n.addNode('c', 'c');
            n.addNode('d', 'd');
            n.addNode('e', 'e');
            n.addNode('f', 'f');
            n.setRule('a', '~(a || b || c) && (d || e || f)');
            n.setRule('b', '~d && (a || b)');
            n.setRule('c', '(c || b)');
            n.setRule('d', '~(c || b)');
            n.setRule('e', '~(d && e) && (c && d)');
            n.setRule('f', '~(f || e) && (a || c)');
            
            %filename = [tempname() '.xml'];
            filename = 'test.xml';
            n.export('sbml', 'filename', filename);
            m = synnetgen.boolnet.BoolNet();
            m = m.import('sbml', 'filename', filename);
            delete(filename);
            
            this.verifyEqual(m, n);
        end
    end
end