angular.module("aircasting").factory('sensors', ['params', '$http', 'spinner', function(params, $http, spinner) {
  var Sensors = function() {
    spinner.show();
    $http.get('/api/sensors', {cache: true}).success(_(this.onSensorsFetch).bind(this));

    this.sensors = {};
    this.tmpSensorId = undefined;
    this.shouldInitSelected = false;
    // this.defaultSensor = "AirBeam2-PM2.5 (µg/m³)"
    this.defaultSensor = "PPD42NS (TtPPCF)"; // FIXME
    this.availableSensors = {};
    this.defaultParameter = {id: "Particulate Matter", label: "Particulate Matter"};
    this.selectedParameter = {};
    this.availableParameters = {};
  };
  Sensors.prototype = {
    onSensorsFetch : function(data, status, headers, config) {
      // Sensors
      var sensors = {};
      _(data).each(function(sensor){
        sensor.id =  sensor.sensor_name + " (" + sensor.unit_symbol + ")";
        sensor.label = sensor.sensor_name + " (" + sensor.unit_symbol + ")";
        if (sensor.label.length >= 42) {
          sensor.select_label = sensor.label.slice(0, 40) + "…";
        } else {
          sensor.select_label = sensor.label;
        }
        sensors[sensor.id] = sensor;
      });
      this.sensors = sensors;

      // Parameters
      var availableParameters = _.uniq(_(this.sensors).map(function(sensor) {
        return sensor["measurement_type"]
      }));
      availableParameters = _.sortBy(availableParameters)
      availableParameters = _.map(availableParameters, function(availableParameter) {
        return ({
          label: availableParameter,
          id: availableParameter
        });
      })
      this.availableParameters = availableParameters;
      // this.selectedParameter = this.defaultParameter;

      // Initialize UI
      this.initSelected();
      spinner.hide();
    },
    initSelected: function() {
      console.log("initSelected")
      var self = this;
      //this is called only for injectors who verified flag - like crowd map

      this.selectedParameter = this.defaultParameter;
      this.availableSensors = _(this.sensors).filter(function(sensor) { return sensor["measurement_type"] == self.selectedParameter["id"]})
      this.availableSensors = this.sensors;
      if(this.shouldInitSelected && !this.isEmpty() && !params.get('data').sensorId){
        console.log("initSelected: if 1")
        if(this.defaultSensor) {
          console.log("initSelected: if 2a")
          params.update({data: {sensorId: this.defaultSensor }});
        } else {
          console.log("initSelected: if 2b")
          params.update({data: {
            sensorId: _(self.sensors).chain().keys().sortBy(function(sensorId) {
              return -1 * self.sensors[sensorId].session_count;
            }).first().value()
          }});
        }
        self.selectedParameter = _(self.availableParameters).find(function(parameter) { return (parameter.id == self.selected()["measurement_type"]) });
        console.log("initSelected: if 3")
      }

      console.log("initSelected end")
      console.log(params.get('data').sensorId)
      console.log(JSON.stringify(this.selectedParameter))
    },
    get: function() {
      var self = this;
      return _(this.sensors).filter(function(sensor) { return (sensor["measurement_type"] == self.selectedParameter.id); });
    },
    getParameters: function() {
      return this.availableParameters;
    },
    isEmpty: function() {
      return _(this.sensors).size() === 0;
    },
    //selected in dropdown
    selected: function() {
      return this.sensors[params.get('data').sensorId];
    },
    selectedId: function() {
      if(!this.selected()){
        return;
      }
      return this.selected().id;
    },
    //used when "all" sensors are choosen
    tmpSelected: function() {
      return this.sensors[params.get('tmp').tmpSensorId];
    },
    tmpSelectedId: function() {
      if(!this.tmpSelected()){
        return;
      }
      return this.tmpSelected().id;
    },
    //pick tmp when "all option is selected
    anySelected: function() {
      return this.selected() || this.tmpSelected();
    },
    anySelectedId: function() {
      if(!this.anySelected()){
        return;
      }
      return this.anySelected().id;
    },
    proceedWithTmp: function() {
      params.update({tmp: {tmpSensorId: this.tmpSensorId}});
    },
    findSensorById: function(id) {
      return this.sensors[id]
    },
    findParameterForSensor: function(sensor) {
      console.log("findParameterForSensor: " + JSON.stringify(sensor))
      return _(this.availableParameters).find(function(parameter) { return (parameter.id == sensor["measurement_type"]) });
    }

  };
  return new Sensors();
}]);

