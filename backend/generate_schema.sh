#!/bin/bash
rm test.db
diesel migration run --database-url=test.db --migration-dir=migrations
