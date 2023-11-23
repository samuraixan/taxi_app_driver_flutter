
class SnapshotData {
  String? driverId;
  Dropoff? dropoff;
  Dropoff? pickup;
  String? pickupAddress;
  String? driverPhone;
  String? dropoffAddress;
  String? riderPhone;
  String? carDetails;
  Dropoff? driverLocation;
  String? driverName;
  String? riderName;
  String? cretaedAt;
  String? paymentMethod;
  String? status;

  SnapshotData(
      {this.driverId,
        this.dropoff,
        this.pickup,
        this.pickupAddress,
        this.driverPhone,
        this.dropoffAddress,
        this.riderPhone,
        this.carDetails,
        this.driverLocation,
        this.driverName,
        this.riderName,
        this.cretaedAt,
        this.paymentMethod,
        this.status});

  SnapshotData.fromJson(Map<String, dynamic> json) {
    driverId = json['driver_id'];
    dropoff =
    json['dropoff'] != null ? new Dropoff.fromJson(json['dropoff']) : null;
    pickup =
    json['pickup'] != null ? new Dropoff.fromJson(json['pickup']) : null;
    pickupAddress = json['pickup_address'];
    driverPhone = json['driver_phone'];
    dropoffAddress = json['dropoff_address'];
    riderPhone = json['rider_phone'];
    carDetails = json['car_details'];
    driverLocation = json['driver_location'] != null
        ? new Dropoff.fromJson(json['driver_location'])
        : null;
    driverName = json['driver_name'];
    riderName = json['rider_name'];
    cretaedAt = json['cretaed_at'];
    paymentMethod = json['payment_method'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['driver_id'] = this.driverId;
    if (this.dropoff != null) {
      data['dropoff'] = this.dropoff!.toJson();
    }
    if (this.pickup != null) {
      data['pickup'] = this.pickup!.toJson();
    }
    data['pickup_address'] = this.pickupAddress;
    data['driver_phone'] = this.driverPhone;
    data['dropoff_address'] = this.dropoffAddress;
    data['rider_phone'] = this.riderPhone;
    data['car_details'] = this.carDetails;
    if (this.driverLocation != null) {
      data['driver_location'] = this.driverLocation!.toJson();
    }
    data['driver_name'] = this.driverName;
    data['rider_name'] = this.riderName;
    data['cretaed_at'] = this.cretaedAt;
    data['payment_method'] = this.paymentMethod;
    data['status'] = this.status;
    return data;
  }
}

class Dropoff {
  String? latitude;
  String? longitude;

  Dropoff({this.latitude, this.longitude});

  Dropoff.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}