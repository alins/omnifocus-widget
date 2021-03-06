app = Application("OmniFocus");
app.includeStandardAdditions = true
doc = app.defaultDocument;

getFlaggedTasks();


function getFlaggedTasks(){
    taskList = [];
	
	tasks = getDueTasks()
    tasks.forEach(function(task)
    {
        context = (task.context() !== null) ? task.context().name() : '';
        project = (task.container() !== null) ? task.container().name() : '';
            taskList.push({
                name: task.name(),
                context: context,
                project: project,
                due: true,
                note: task.note(),
				id: task.id(),
                taskDefer: formatDate (task.deferDate()),
                taskDue: formatDate (task.dueDate()),
                projDefer: (task.containingProject() != null ? task.containingProject().deferDate() : null),
				dueToday: (taskDueInDays(task.dueDate()) <= 1),
				
            });
    });	
	
    tasks = getAvailableTasks()
    tasks.forEach(function(task)
    {
        context = (task.context() !== null) ? task.context().name() : '';
        project = (task.container() !== null) ? task.container().name() : '';
            taskList.push({
                name: task.name(),
                context: context,
                project: project,
                due: false,
                note: task.note(),
				id: task.id(),
                taskDefer: formatDate (task.deferDate()),
                taskDue: formatDate (task.dueDate()),
                projDefer: (task.containingProject() != null ? task.containingProject().deferDate() : null),
				dueToday: false,
            });
    });
	
    retObj = {
        'tasks' : taskList,
        'count' : taskList.length
    };

    return JSON.stringify(retObj);
}

function formatDate(date) {
	if (date == null) return ''
    var year = date.getFullYear(),
        month = date.getMonth() + 1, // months are zero indexed
        day = date.getDate(),
        hour = date.getHours(),
        minute = date.getMinutes(),
        second = date.getSeconds(),
        hourFormatted = hour % 12 || 12, // hour returned in 24 hour format
        minuteFormatted = minute < 10 ? "0" + minute : minute,
        morning = hour < 12 ? "am" : "pm";

    return year + "-" + month + "-" + day + " " + hourFormatted + ":" +
            minuteFormatted + morning;
}

function getAvailableTasks() {
    availableTasks = [];
    tasks = doc.flattenedTasks.whose({completed: false, blocked:false})();
    
    tasks.forEach(function(task){
        if (task.containingProject() != null && 
            task.containingProject().deferDate() != null &&
            task.containingProject().deferDate() > task.deferDate()) 
        {
            if (task.containingProject().deferDate() > Date.now()) {
		if (tasks[task]) {
			tasks.remove(task)
		}
            }
        }       
        
        if(task.deferDate() != null && 
           task.completionDate() == null && 
           task.deferDate() < Date.now())
        {
            availableTasks.push(task);
        }
    });
    return availableTasks;
}

function getDueTasks() {
    dueTasks = [];
    tasks = doc.flattenedTasks.whose({completed: false})();
    
	dueDate = new Date()
	dueDate .setDate(dueDate.getDate() + 1.5)
	
    tasks.forEach(function(task){
        if (task.containingProject() != null && 
            task.containingProject().dueDate() != null &&
            task.containingProject().dueDate() > task.dueDate()) 
        {
            if (task.containingProject().dueDate() > dueDate) {
				if (tasks[task]) {
					tasks.remove(task)
				}
            }
        }       
        
		
        if(task.dueDate() != null && 
           task.dueDate() < dueDate)
        {
            dueTasks.push(task);
        }
    });
    return dueTasks;
}

function taskDueInDays(taskDueDate) {
	if (taskDueDate == null) {
		return null
	} else {
		dueInMillis = (taskDueDate.getTime() - new Date().getTime())
		return dueInMillis/1000/60/60/24
	}
}
