const { TableClient } = require('@azure/data-tables');

class StateManager {
  constructor() {
    this.tableName = 'gmailstate';
    this.partitionKey = 'gmail';
    this.rowKey = 'lastcheck';
    
    // Initialize table client if connection string is available
    if (process.env.AZURE_STORAGE_CONNECTION_STRING) {
      this.tableClient = TableClient.fromConnectionString(
        process.env.AZURE_STORAGE_CONNECTION_STRING,
        this.tableName
      );
      this.initialized = this.initializeTable();
    } else {
      console.warn('Azure Storage connection string not found. Using in-memory state.');
      this.useInMemory = true;
      this.inMemoryState = {};
    }
  }

  async initializeTable() {
    try {
      await this.tableClient.createTable();
    } catch (error) {
      // Table might already exist, which is fine
      if (error.statusCode !== 409) {
        console.error('Error creating table:', error);
      }
    }
  }

  async getLastCheckedTime() {
    if (this.useInMemory) {
      return this.inMemoryState.lastChecked || Math.floor(Date.now() / 1000) - 3600;
    }

    try {
      await this.initialized;
      const entity = await this.tableClient.getEntity(this.partitionKey, this.rowKey);
      return entity.lastChecked || Math.floor(Date.now() / 1000) - 3600;
    } catch (error) {
      if (error.statusCode === 404) {
        // Entity doesn't exist yet
        return Math.floor(Date.now() / 1000) - 3600;
      }
      console.error('Error getting last checked time:', error);
      return Math.floor(Date.now() / 1000) - 3600;
    }
  }

  async updateLastCheckedTime(timestamp) {
    if (this.useInMemory) {
      this.inMemoryState.lastChecked = timestamp;
      return;
    }

    try {
      await this.initialized;
      const entity = {
        partitionKey: this.partitionKey,
        rowKey: this.rowKey,
        lastChecked: timestamp,
        updatedAt: new Date().toISOString()
      };
      
      await this.tableClient.upsertEntity(entity, 'Replace');
    } catch (error) {
      console.error('Error updating last checked time:', error);
    }
  }

  async getLastHistoryId() {
    if (this.useInMemory) {
      return this.inMemoryState.historyId;
    }

    try {
      await this.initialized;
      const entity = await this.tableClient.getEntity(this.partitionKey, 'historyid');
      return entity.historyId;
    } catch (error) {
      if (error.statusCode === 404) {
        return null;
      }
      console.error('Error getting history ID:', error);
      return null;
    }
  }

  async updateLastHistoryId(historyId) {
    if (this.useInMemory) {
      this.inMemoryState.historyId = historyId;
      return;
    }

    try {
      await this.initialized;
      const entity = {
        partitionKey: this.partitionKey,
        rowKey: 'historyid',
        historyId: historyId,
        updatedAt: new Date().toISOString()
      };
      
      await this.tableClient.upsertEntity(entity, 'Replace');
    } catch (error) {
      console.error('Error updating history ID:', error);
    }
  }
}

module.exports = StateManager;