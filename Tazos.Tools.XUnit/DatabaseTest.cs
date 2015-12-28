﻿using System;

namespace Tazos.Tools.XUnit
{
    public abstract class DatabaseTest : IDisposable
    {
        protected abstract DatabaseCreator DatabaseCreator { get; }
        protected abstract DatabaseRemover DatabaseRemover { get; }


        private readonly string connectionStringName;

        protected DatabaseTest(string connectionStringName)
        {
            this.connectionStringName = connectionStringName;

            TestEnviromentCleaner = new DefaultTestEnviromentCleaner(DatabaseRemover);
            TestEnviromentPreparer =
            new DefaultTestEnviromentPreparer(DatabaseCreator, connectionStringName);
            Token = TestEnviromentPreparer.Prepare();
        }

        public DefaultTestEnviromentCleaner TestEnviromentCleaner { get; set; }

        public DefaultTestEnviromentPreparer TestEnviromentPreparer { get; set; }

        protected readonly DefaultTestToken Token;

        public void Dispose()
        {
            TestEnviromentCleaner.Clean(Token);
        }
    }
}