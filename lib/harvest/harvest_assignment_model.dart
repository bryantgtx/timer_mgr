//  A Harvest Assignment represents a collection of clients, projects and tasks assigned to a user.
class HarvestAssignment {
  final List<HarvestClient> clients;
  final DateTime createdAt;
  HarvestAssignment({this.clients, this.createdAt});

  static List<HarvestClient> _reduceClients(List<HarvestClient> mapClients) {
    List<HarvestClient> reduceClients = [];
    mapClients.forEach((mapClient) {
      HarvestClient matchClient = reduceClients
          .firstWhere((reduceClient) => mapClient.name == reduceClient.name,
              orElse: () => null);
      if (matchClient != null) {
        matchClient.projects.addAll(mapClient.projects);
      }
      else {
        reduceClients.add(mapClient);
      }
    });
    return reduceClients;
  }

  static void _sortAndFilterClients(List<HarvestClient> clients) {
    clients.sort((a,b) => a.name.compareTo(b.name));
    clients.forEach((client) { 
      client.projects.sort((a, b) => a.toString().compareTo(b.toString()));
      client.projects.forEach((project) { 
        project.tasks.removeWhere((task) => task.isActive == false);
        project.tasks.sort((a, b) => a.toString().compareTo(b.toString()));
      });
    });
  }

  factory HarvestAssignment.fromApi(Map<String, dynamic> json) {
    List<dynamic> projectAssignmentsJson = json['project_assignments'] ?? [];
    var mapClients = projectAssignmentsJson.map((e) => HarvestClient.fromApi(e)).toList();
    var reduceClients = _reduceClients(mapClients);
    _sortAndFilterClients(reduceClients);
    return HarvestAssignment(
      clients: reduceClients,
      createdAt: DateTime.now(),
    );
  }

  factory HarvestAssignment.fromHive(Map<dynamic, dynamic> rawAssignment) {
    return HarvestAssignment(
      createdAt: rawAssignment['createdAt'],
      clients: (rawAssignment['clients'] as List<dynamic>).map((e) => HarvestClient.fromHive(e)).toList(),
    );
  }

  Map<String, dynamic> toHive() {
    var hiveMap = Map<String, dynamic>();
    hiveMap['createdAt'] = createdAt;
    hiveMap['clients'] = clients.map((client) => client.toHive()).toList();

    return hiveMap;
  }
}

class HarvestClient {
  final int id;
  final String name;
  final List<HarvestProject> projects;

  HarvestClient({this.id, this.name, this.projects})
    : assert(name != null), assert(id != null);

  factory HarvestClient.fromApi(Map<String, dynamic> json) {
    Map<String, dynamic> clientJson = json['client'];
    Map<String, dynamic> projectJson = json['project'];
    List<dynamic> taskAssignmentsJson = json['task_assignments'];
    List<HarvestProject> projects = [HarvestProject.fromApi(projectJson, taskAssignmentsJson)];
    return HarvestClient(
      id: clientJson['id'],
      name: clientJson['name'],
      projects: projects,
    );
  }

  factory HarvestClient.fromHive(Map<dynamic, dynamic> rawAssignment) {
    return HarvestClient(
      id: rawAssignment['id'],
      name: rawAssignment['name'],
      projects: (rawAssignment['projects'] as List<dynamic>).map((e) => HarvestProject.fromHive(e)).toList(),
    );
  }

  Map<String, dynamic> toHive() {
    var hiveMap = Map<String, dynamic>();
    hiveMap['id'] = id;
    hiveMap['name'] = name;
    hiveMap['projects'] = projects.map((project) => project.toHive()).toList();

    return hiveMap;
  }
}

class HarvestProject {
  final int id;
  final String name;
  final String code;
  final bool isBillable;
  final List<HarvestTask> tasks;

  HarvestProject({this.id, this.name, this.code, this.isBillable, this.tasks})
    : assert(name != null), assert(id != null);

  factory HarvestProject.fromApi(Map<String, dynamic> json, List<dynamic> taskAssignmentsJson) {
    print('creating project ${json['name']}');
    List<HarvestTask> tasks = taskAssignmentsJson.map((e) => HarvestTask.fromApi(e)).toList();
    return HarvestProject(
      id: json['id'],
      name: json['name'],
      code: json['code'] ?? '',
      isBillable: json['is_billable'] ?? false,
      tasks: tasks,
    );
  }

  factory HarvestProject.fromHive(Map<dynamic, dynamic> rawAssignment) {
    return HarvestProject(
      id: rawAssignment['id'],
      name: rawAssignment['name'],
      code: rawAssignment['code'],
      isBillable: rawAssignment['isBillable'],
      tasks: (rawAssignment['tasks'] as List<dynamic>).map((e) => HarvestTask.fromHive(e)).toList(),
    );
  }

  Map<String, dynamic> toHive() {
    var hiveMap = Map<String, dynamic>();
    hiveMap['id'] = id;
    hiveMap['name'] = name;
    hiveMap['code'] = code;
    hiveMap['isBillable'] = isBillable;
    hiveMap['tasks'] = tasks.map((project) => project.toHive() ).toList();

    return hiveMap;
  }

  String toString()  {
    var codePart = code.isEmpty ? '' : '[$code] ';
    return '$codePart$name';
  }
}

// Harvest breaks out the task assignment from the task, and gives them separate ids, 
// but when sending a time entry, all they need is the task id.  We are combining
// these two entities in Harvest into one for our model.
class HarvestTask {
  final int id;
  final int assignmentId;
  final bool isBillable;
  final bool isActive;
  final String name;
  final bool isSelected;

  HarvestTask({this.assignmentId, this.isBillable, this.isActive, this.id, this.name, this.isSelected = false})
    : assert(name != null), assert(id != null);

  factory HarvestTask.fromApi(Map<String, dynamic> json) {
    Map<String, dynamic> taskJson = json['task'] ?? [];
    return HarvestTask(
      assignmentId: json['id'] ?? 0,
      isBillable: json['billable'] ?? false,
      isActive: json['is_active'] ?? false,
      id: taskJson['id'],
      name: taskJson['name'],
    );
  }

  factory HarvestTask.fromHive(Map<dynamic, dynamic> rawAssignment) {
    return HarvestTask(
      assignmentId: rawAssignment['assignmentId'],
      isBillable: rawAssignment['isBillable'],
      isActive: rawAssignment['isActive'],
      id: rawAssignment['id'],
      name: rawAssignment['name'],
    );
  }

  Map<String, dynamic> toHive() {
    var hiveMap = Map<String, dynamic>();
    hiveMap['assignmentId'] = assignmentId;
    hiveMap['isBillable'] = isBillable;
    hiveMap['isActive'] = isActive;
    hiveMap['id'] = id;
    hiveMap['name'] = name;

    return hiveMap;
  }

  String toString() => '$name';
}
