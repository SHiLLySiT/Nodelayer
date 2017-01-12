'use strict';

class Project {
    constructor() {
        this._nodes = {};
        this._connections = {};
        this._templates = {};
    }

    // -------------------------------------------------------------- TEMPLATES
    createTemplate() {
        let template = {
            uuid: this._generateUUID(),
            name: "New Template",
            properties: {},
        }
        this._templates[template.uuid] = template;
        return template;
    }

    getTemplates() {
        return this._templates;
    }

    getTemplate(uuid) {
        return this._templates[uuid];
    }

    updateTemplate(uuid, data) {
        let template = this._templates[uuid];
        if (data.hasOwnProperty('name')) {
            template.name = data.name;
        }
        return template;
    }

    deleteTemplate(uuid) {
        if (this._templates.hasOwnProperty(uuid)) {
            delete this._templates[uuid];
        }
    }

    createProperty(templateUUID) {
        // create property
        let template = this._templates[templateUUID];
        let property = {
            uuid: this._generateUUID(),
            name: "New Property",
            type: "string",
            defaultValue: "",
        };
        template.properties[property.uuid] = property;

        // add property to nodes
        for (let n in this._nodes) {
            let node = this._nodes[n];
            if (node.template == templateUUID) {
                if (!node.properties.hasOwnProperty(property.uuid)) {
                    node.properties[property.uuid] = {
                        value: property.defaultValue,
                    }
                }
            }
        }
        return property;
    }

    getProperty(templateUUID, propertyUUID) {
        if (this._templates.hasOwnProperty(templateUUID)) {
            return this._templates[uuid].properties[propertyUUID];
        }
        return null;
    }

    updateProperty(templateUUID, propertyUUID, data) {
        let template = this._templates[templateUUID];
        if (template == null) {
            return;
        }

        let property = template.properties[propertyUUID];
        if (property == null) {
            return;
        }

        if (data.hasOwnProperty('name')) {
            property.name = data.name;
        }

        if (data.hasOwnProperty('defaultValue')) {
            property.defaultValue = data.defaultValue;
            if (property.type == 'integer') {
                if (!utils.isInteger(property.defaultValue)) {
                    property.defaultValue = 0;
                }
            }
        }

        if (data.hasOwnProperty('type')) {
            property.type = data.type;
            // update default value if type changes
            if (property.type == 'boolean') {
                property.defaultValue = false;
            } else if (property.type == 'integer') {
                property.defaultValue = 0;
            } else if (property.type == 'string') {
                property.defaultValue = "";
            }
        }

        return property
    }

    deleteProperty(templateUUID, propertyUUID) {
        // delete property
        if (this._templates.hasOwnProperty(templateUUID)) {
            let template = this._templates[templateUUID];
            if (template.properties.hasOwnProperty(propertyUUID)) {
                delete template.properties[propertyUUID];
            }
        }

        // remove property from nodes
        for (let n in this._nodes) {
            let node = this._nodes[n];
            if (node.template == templateUUID) {
                if (node.properties.hasOwnProperty(propertyUUID)) {
                    delete node.properties[propertyUUID];
                }
            }
        }
    }

    // ------------------------------------------------------------------ NODES
    createNode(x, y) {
        let node = {
            uuid: this._generateUUID(),
            template: null,
            x:x,
            y:y,
            properties: {},
            connections: [],
        }
        this._nodes[node.uuid] = node;
        return node;
    }

    getNode(uuid) {
        return this._nodes[uuid];
    }

    updateNode(uuid, data) {
        let node = this._nodes[uuid];
        if (data.hasOwnProperty('x')) {
            node.x = data.x;
        }
        if (data.hasOwnProperty('y')) {
            node.y = data.y;
        }
        return node;
    }

    deleteNode(uuid) {
        if (this._nodes.hasOwnProperty(uuid)) {
            delete this._nodes[uuid];
        }
    }

    // ------------------------------------------------------------ CONNECTIONS
    createConnection(startUUID, endUUID) {
        let start = this._nodes[startUUID];
        let end = this._nodes[endUUID];
        if (this._areNodesConnected(start, end)) {
            return;
        }

        let connection = {
            uuid: this._generateUUID(),
            start: startUUID,
            end: endUUID,
        }

        start.connections.push(connection.uuid);
        end.connections.push(connection.uuid);
        this._connections[connection.uuid] = connection;
        return connection;
    }

    getConnection(uuid) {
        return this._connections[uuid];
    }

    updateConnection(uuid, data) {
        let connection = this._connections[uuid];
        // TODO: update properties
        return connection;
    }

    deleteConnection(uuid) {
        if (this._connections.hasOwnProperty(uuid)) {
            let connection = this._connections[uuid];
            let start = this._nodes[connection.start];
            let end = this._nodes[connection.end];
            this._removeConnectionFromNode(start, uuid);
            this._removeConnectionFromNode(end, uuid);
            delete this._connections[uuid];
        }
    }

    // ------------------------------------------------------------ SAVE/LOAD
    saveProject(path) {

    }

    loadProject(path) {

    }

    saveWeb(path) {

    }

    loadWeb(path) {

    }

    // ---------------------------------------------------------------- PRIVATE
    _generateUUID() {
        var d = new Date().getTime();
        var uuid = '0xxxxxxxxxxxxxxxyxxxxxxxxxxxxxxx'.replace(/[xy]/g,
            function(c) {
                var r = (d + Math.random() * 16) % 16 | 0;
                d = Math.floor(d / 16);
                return (c == 'x' ? r : (r&0x3 | 0x8)).toString(16);
            }
        );
        return uuid;
    }

    _areNodesConnected(a, b) {
        if (a.connections.length == 0 || b.connections.length == 0) {
            return false;
        }
        for (let i = 0; i < a.connections.length; i++) {
            let uuid = a.connections[i];
            let connection = this._connections[uuid];
            if (connection.start == b.uuid || connection.end == b.uuid) {
                return true;
            }
        }
        return false;
    }

    _removeConnectionFromNode(node, connectionUUID) {
        let index = node.connections.indexOf(connectionUUID);
        if (index != -1) {
            node.connections.splice(index, 1);
        }
    }
}

module.exports = Project;
