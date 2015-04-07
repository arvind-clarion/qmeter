      function drawlineChart( chartData ){

        var xPadding = 30;
        var yPadding = 30;
        var set = chartData.dataset;
        var label = chartData.labels;
        var graph = $("#"+chartData.node+"");
        var c = graph[0].getContext('2d');            

        c.lineWidth = 2;
        c.font = '8pt sans-serif';
        c.textAlign = "center";
        c.strokeStyle = '#8e8e8e';
        c.fillStyle = '#4e4e4e';

        // Draw the axises
        c.beginPath();
        c.moveTo(xPadding, 0);
        c.lineTo(xPadding, graph.height() - yPadding);
        c.lineTo(graph.width(), graph.height() - yPadding);
        c.stroke();

        // Returns the max Y value in our data list
        function getMaxY() {
          var max = 0;
          for(var i = 0; i < set.length; i ++) {
            if(set[i] > max) {
              max = set[i];
            }
          }
          max += 10 - max % 10;
          return max;
        }

        // Return the x pixel for a graph point
        function getXPixel(val) {
          return ((graph.width() - xPadding) / label.length) * val + (xPadding * 1.5);
        }
        
        // Return the y pixel for a graph point
        function getYPixel(val) {
          return graph.height() - (((graph.height() - yPadding) / getMaxY()) * val) - yPadding;
        }
        
        // Draw the X value texts
        for(var i = 0; i < label.length; i ++) {
          c.fillText(label[i], getXPixel(i), graph.height() - yPadding + 15);
        }
        
        // Draw the Y value texts
        c.textAlign = "right"
        c.textBaseline = "middle";
        var breakperiod = chartData.ybreakperiod;
        for(var i = 0; i <= getMaxY(); i += breakperiod) {
          c.fillText(i, xPadding - 10, getYPixel(i));
        }
        
        c.strokeStyle = chartData.pathcolor;
        c.fillStyle = chartData.fillcolor;

        // Draw the line graph
        c.beginPath();
        c.moveTo(getXPixel(0), getYPixel(set[0]));
        for(var i = 1; i < set.length; i ++) {
          c.lineTo(getXPixel(i), getYPixel(set[i]));
        }
        c.stroke();
            
        // Draw the graph points
        for(var i = 0; i < set.length; i ++) {  
          c.beginPath();
          c.arc(getXPixel(i), getYPixel(set[i]), 3, 0, Math.PI * 2, true);
          c.fill();
        }
      }

     
