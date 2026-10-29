// Field Notes keeps the paper/editor state in History objects. Fieldbook adds a thin
// grouping layer around those same sheets: chapters/projects own ordered page ids, while
// the existing sheet histories remain unchanged.
var MAX_SHEETS = 32
var MAX_PROJECTS = 32

function cleanTitle(title, fallback) {
    var value = String(title || "").replace(/\s+/g, " ").trim().slice(0, 60)
    return value || fallback
}

function nextId(values, prefix) {
    var highest = 0
    var head = prefix + "-"
    for (var i = 0; i < values.length; i++) {
        var id = String(values[i] || "")
        if (id.indexOf(head) === 0)
            highest = Math.max(highest, Number(id.slice(head.length)) || 0)
    }
    return prefix + "-" + (highest + 1)
}

function defaultPageIds(count) {
    var ids = []
    for (var i = 0; i < count; i++)
        ids.push("page-" + (i + 1))
    return ids
}

function normalizePageIds(raw, count) {
    var ids = []
    var seen = {}
    for (var i = 0; i < count; i++) {
        var candidate = Array.isArray(raw) ? String(raw[i] || "") : ""
        if (!/^page-[A-Za-z0-9_-]+$/.test(candidate) || seen[candidate])
            candidate = nextId(ids, "page")
        seen[candidate] = true
        ids.push(candidate)
    }
    return ids.length === count ? ids : defaultPageIds(count)
}

function normalizeProjects(raw, pageIds) {
    var projects = []
    var usedProjects = {}
    var assigned = {}
    var source = Array.isArray(raw) ? raw : []

    for (var i = 0; i < source.length && projects.length < MAX_PROJECTS; i++) {
        var candidate = source[i]
        if (!candidate || typeof candidate !== "object")
            continue
        var projectId = String(candidate.id || "")
        if (!/^project-[A-Za-z0-9_-]+$/.test(projectId) || usedProjects[projectId])
            projectId = nextId(projects.map(function(project) { return project.id }), "project")
        usedProjects[projectId] = true
        var project = { id: projectId, title: cleanTitle(candidate.title, "Chapter " + (projects.length + 1)), pageIds: [] }
        var rawPages = Array.isArray(candidate.pageIds) ? candidate.pageIds : []
        for (var j = 0; j < rawPages.length; j++) {
            var pageId = String(rawPages[j] || "")
            if (pageIds.indexOf(pageId) >= 0 && !assigned[pageId]) {
                assigned[pageId] = true
                project.pageIds.push(pageId)
            }
        }
        projects.push(project)
    }

    if (projects.length === 0)
        projects.push({ id: "project-1", title: "Field Notes", pageIds: [] })

    for (var k = 0; k < pageIds.length; k++) {
        if (!assigned[pageIds[k]])
            projects[0].pageIds.push(pageIds[k])
    }

    return projects
}

function projectForPage(projects, pageId) {
    for (var i = 0; i < projects.length; i++) {
        if (projects[i].pageIds.indexOf(pageId) >= 0)
            return projects[i].id
    }
    return projects.length > 0 ? projects[0].id : ""
}

function normalizeMetadata(pageIds, projects, count) {
    var ids = normalizePageIds(pageIds, count)
    return { pageIds: ids, projects: normalizeProjects(projects, ids) }
}

function create(histories, current, pageIds, projects) {
    var sheets = histories && histories.length ? histories : []
    var index = Math.max(0, Math.min(sheets.length - 1, Math.floor(current) || 0))
    var metadata = normalizeMetadata(pageIds, projects, sheets.length)
    return {
        sheets: sheets,
        pageIds: metadata.pageIds,
        projects: metadata.projects,
        current: index,
        currentProjectId: projectForPage(metadata.projects, metadata.pageIds[index])
    }
}

function isBlank(history) {
    return history.present.objects.length === 0 && !history.present.title
}

function replaceCurrent(notebook, history) {
    if (history === notebook.sheets[notebook.current])
        return notebook
    var sheets = notebook.sheets.slice()
    sheets[notebook.current] = history
    return create(sheets, notebook.current, notebook.pageIds, notebook.projects)
}

function removeAt(notebook, index) {
    var sheets = notebook.sheets.slice()
    var pageIds = notebook.pageIds.slice()
    sheets.splice(index, 1)
    var removedPage = pageIds.splice(index, 1)[0]
    var projects = notebook.projects.map(function(project) {
        return { id: project.id, title: project.title, pageIds: project.pageIds.filter(function(pageId) { return pageId !== removedPage }) }
    }).filter(function(project) { return project.pageIds.length > 0 })
    return create(sheets, 0, pageIds, projects)
}

function select(notebook, index) {
    if (index < 0 || index >= notebook.sheets.length || index === notebook.current)
        return notebook
    var next = notebook
    if (isBlank(notebook.sheets[notebook.current])) {
        next = removeAt(notebook, notebook.current)
        if (index > notebook.current)
            index--
        if (next.sheets.length === 0)
            return notebook
    }
    return create(next.sheets, index, next.pageIds, next.projects)
}

function canAdd(notebook) {
    return notebook.sheets.length < MAX_SHEETS && !isBlank(notebook.sheets[notebook.current])
}

function add(notebook, history) {
    if (!canAdd(notebook))
        return notebook
    var sheets = notebook.sheets.concat([history])
    var pageIds = notebook.pageIds.concat([nextId(notebook.pageIds, "page")])
    var projects = notebook.projects.map(function(project) {
        return { id: project.id, title: project.title, pageIds: project.pageIds.slice() }
    })
    var currentProject = projectForPage(projects, notebook.pageIds[notebook.current])
    for (var i = 0; i < projects.length; i++) {
        if (projects[i].id === currentProject) {
            projects[i].pageIds.push(pageIds[pageIds.length - 1])
            break
        }
    }
    return create(sheets, sheets.length - 1, pageIds, projects)
}

function addProject(notebook, history, title) {
    if (notebook.projects.length >= MAX_PROJECTS || notebook.sheets.length >= MAX_SHEETS)
        return notebook

    var base = notebook
    if (isBlank(notebook.sheets[notebook.current]))
        base = removeAt(notebook, notebook.current)

    var pageId = nextId(base.pageIds, "page")
    var projectId = nextId(base.projects.map(function(project) { return project.id }), "project")
    var projects = base.projects.map(function(project) {
        return { id: project.id, title: project.title, pageIds: project.pageIds.slice() }
    })
    projects.push({ id: projectId, title: cleanTitle(title, "New chapter"), pageIds: [pageId] })
    return create(base.sheets.concat([history]), base.sheets.length, base.pageIds.concat([pageId]), projects)
}

function selectProject(notebook, projectId) {
    for (var i = 0; i < notebook.projects.length; i++) {
        var project = notebook.projects[i]
        if (project.id !== projectId || project.pageIds.length === 0)
            continue
        var pageIndex = notebook.pageIds.indexOf(project.pageIds[0])
        if (pageIndex >= 0)
            return select(notebook, pageIndex)
    }
    return notebook
}

function renameProject(notebook, projectId, title) {
    var clean = cleanTitle(title, "New chapter")
    var changed = false
    var projects = notebook.projects.map(function(project) {
        if (project.id !== projectId)
            return project
        changed = project.title !== clean
        return { id: project.id, title: clean, pageIds: project.pageIds.slice() }
    })
    return changed ? create(notebook.sheets, notebook.current, notebook.pageIds, projects) : notebook
}

if (typeof module !== "undefined") {
    module.exports = {
        MAX_SHEETS: MAX_SHEETS,
        MAX_PROJECTS: MAX_PROJECTS,
        create: create,
        isBlank: isBlank,
        replaceCurrent: replaceCurrent,
        select: select,
        canAdd: canAdd,
        add: add,
        addProject: addProject,
        selectProject: selectProject,
        renameProject: renameProject
    }
}
