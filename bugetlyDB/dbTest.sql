create database TEST collate SQL_Latin1_General_CP1_CI_AS
go

use TEST
go

grant connect on database :: TEST to dbo
go

grant view any column encryption key definition, view any column master key definition on database :: TEST to [public]
go

create table dbo.PlanuriAbonament
(
    PlanID    int identity
        primary key,
    Nume      nvarchar(50)   not null,
    PretLunar decimal(10, 2) not null,
    Descriere nvarchar(255)
)
go

create table dbo.Utilizatori
(
    UtilizatorID     int identity
        primary key,
    NumeComplet      nvarchar(100) not null,
    Email            nvarchar(100) not null
        unique,
    Parola           nvarchar(100) not null,
    PlanID           int           not null
        references dbo.PlanuriAbonament,
    DataInregistrare datetime default getdate(),
    Activ            bit      default 1
)
go

create table dbo.ConturiBancare
(
    ContID         int identity
        primary key,
    UtilizatorID   int          not null
        references dbo.Utilizatori,
    IBAN           nvarchar(34) not null
        unique,
    Sold           decimal(18, 2) default 0,
    TipCont        nvarchar(50),
    Activ          bit            default 1,
    DataDeschidere datetime       default getdate()
)
go

create table dbo.Tranzactii
(
    TranzactieID   int identity
        primary key,
    ContID         int            not null
        references dbo.ConturiBancare,
    Tip            nvarchar(50),
    Suma           decimal(18, 2) not null,
    DataTranzactie datetime default getdate(),
    Descriere      nvarchar(255)
)
go

create table sys.backup_metadata_store
(
    backup_metadata_uuid      uniqueidentifier not null,
    database_guid             uniqueidentifier not null,
    physical_database_name    nvarchar(128)    not null,
    time_zone                 smallint         not null,
    first_lsn                 numeric(25)      not null,
    last_lsn                  numeric(25)      not null,
    checkpoint_lsn            numeric(25)      not null,
    database_backup_lsn       numeric(25)      not null,
    backup_start_date         datetime2        not null,
    backup_finish_date        datetime2        not null,
    backup_type               char             not null,
    backup_storage_redundancy nvarchar(64),
    database_version          int              not null,
    backup_size               numeric(20)      not null,
    compressed_backup_size    numeric(20)      not null,
    server_name               nvarchar(128)    not null,
    is_damaged                bit,
    last_recovery_fork_guid   uniqueidentifier,
    differential_base_lsn     numeric(25),
    differential_base_guid    uniqueidentifier,
    backup_path               nvarchar(260)    not null,
    last_valid_restore_time   datetime2,
    compression_algorithm     nvarchar(32)
)
go

create unique clustered index IX_backup_metadata_uuid
    on sys.backup_metadata_store (backup_metadata_uuid)
go

create index IX_backup_metadata_type_finish_date
    on sys.backup_metadata_store (backup_type, backup_finish_date)
go

create table sys.db_ledger_blocks
(
    block_id               bigint   not null,
    version                smallint not null,
    transactions_root_hash varbinary(32),
    block_size             int      not null,
    previous_block_hash    varbinary(32)
)
go

create unique clustered index ci_block_id
    on sys.db_ledger_blocks (block_id)
go

create table sys.db_ledger_digest_locations
(
    storage_type         int     not null,
    path                 nvarchar(4000),
    last_digest_block_id bigint,
    is_current           tinyint not null
)
go

create unique clustered index ci_type_and_path
    on sys.db_ledger_digest_locations (storage_type, path)
go

create table sys.db_ledger_transactions
(
    transaction_id          bigint    not null,
    block_id                bigint    not null,
    transaction_ordinal     int       not null,
    version                 tinyint   not null,
    type                    tinyint   not null,
    commit_ts               datetime2 not null,
    table_hashes            varbinary(max),
    commit_LSN              varbinary(10),
    transaction_description nvarchar(max),
    principal_name          sysname   not null
)
go

create unique clustered index ci_block_id
    on sys.db_ledger_transactions (block_id, transaction_ordinal)
go

create unique index nci_transaction_id
    on sys.db_ledger_transactions (transaction_id)
go

create table sys.filestream_tombstone_2073058421
(
    oplsn_fseqno             int              not null,
    oplsn_bOffset            int              not null,
    oplsn_slotid             int              not null,
    file_id                  int              not null,
    rowset_guid              uniqueidentifier not null,
    column_guid              uniqueidentifier,
    filestream_value_name    nvarchar(260) collate Latin1_General_BIN,
    transaction_sequence_num bigint           not null,
    status                   bigint           not null,
    size                     bigint
)
go

create unique clustered index FSTSClusIdx
    on sys.filestream_tombstone_2073058421 (oplsn_fseqno, oplsn_bOffset, oplsn_slotid)
go

create index FSTSNCIdx
    on sys.filestream_tombstone_2073058421 (file_id, rowset_guid, column_guid, oplsn_fseqno, oplsn_bOffset,
                                            oplsn_slotid)
go

create table sys.filetable_updates_2105058535
(
    table_id      bigint           not null,
    oplsn_fseqno  int              not null,
    oplsn_bOffset int              not null,
    oplsn_slotid  int              not null,
    item_guid     uniqueidentifier not null
)
go

create unique clustered index FFtUpdateIdx
    on sys.filetable_updates_2105058535 (table_id, oplsn_fseqno, oplsn_bOffset, oplsn_slotid, item_guid)
go

create table sys.ledger_columns_history_internal
(
    object_id                    int                                                     not null,
    column_id                    int                                                     not null,
    column_name                  sysname                                                 not null,
    operation_type               int                                                     not null,
    ledger_start_transaction_id  bigint generated always as transaction_id start hidden  not null,
    ledger_end_transaction_id    bigint generated always as transaction_id end hidden,
    ledger_start_sequence_number bigint generated always as sequence_number start hidden not null,
    ledger_end_sequence_number   bigint generated always as sequence_number end hidden
)
go

create unique clustered index ci_ledger_columns_history_internal
    on sys.ledger_columns_history_internal (object_id, column_id)
go

create table sys.ledger_columns_history_internal_history
(
    object_id                    int     not null,
    column_id                    int     not null,
    column_name                  sysname not null,
    operation_type               int     not null,
    ledger_start_transaction_id  bigint  not null,
    ledger_end_transaction_id    bigint,
    ledger_start_sequence_number bigint  not null,
    ledger_end_sequence_number   bigint
)
go

create clustered index ci_ledger_columns_history_internal_history
    on sys.ledger_columns_history_internal_history (object_id, column_id)
go

create table sys.ledger_tables_history_internal
(
    schema_name                     sysname                                                 not null,
    table_name                      sysname                                                 not null,
    object_id                       int                                                     not null,
    ledger_view_schema_name         sysname                                                 not null,
    ledger_view_name                sysname                                                 not null,
    operation_type                  int                                                     not null,
    ledger_start_transaction_id     bigint generated always as transaction_id start hidden  not null,
    ledger_end_transaction_id       bigint generated always as transaction_id end hidden,
    ledger_start_sequence_number    bigint generated always as sequence_number start hidden not null,
    ledger_end_sequence_number      bigint generated always as sequence_number end hidden,
    status                          int,
    transaction_id_column_name      sysname,
    sequence_number_column_name     sysname,
    operation_type_column_name      sysname,
    operation_type_desc_column_name sysname
)
go

create unique clustered index ci_ledger_tables_history_internal
    on sys.ledger_tables_history_internal (object_id)
go

create table sys.ledger_tables_history_internal_history
(
    schema_name                     sysname not null,
    table_name                      sysname not null,
    object_id                       int     not null,
    ledger_view_schema_name         sysname not null,
    ledger_view_name                sysname not null,
    operation_type                  int     not null,
    ledger_start_transaction_id     bigint  not null,
    ledger_end_transaction_id       bigint,
    ledger_start_sequence_number    bigint  not null,
    ledger_end_sequence_number      bigint,
    status                          int,
    transaction_id_column_name      sysname,
    sequence_number_column_name     sysname,
    operation_type_column_name      sysname,
    operation_type_desc_column_name sysname
)
go

create clustered index ci_ledger_tables_history_internal_history
    on sys.ledger_tables_history_internal_history (object_id)
go

create table sys.persistent_version_store
(
    xdes_ts_push      bigint          not null,
    xdes_ts_tran      bigint          not null,
    subid_push        int,
    subid_tran        int,
    rowset_id         bigint          not null,
    sec_version_rid   binary(8)       not null,
    min_len           smallint,
    seq_num           bigint,
    prev_row_in_chain binary(8)       not null,
    row_version       varbinary(8000) not null
)
go

create table sys.persistent_version_store_long_term
(
    xdes_ts_push      bigint          not null,
    xdes_ts_tran      bigint          not null,
    subid_push        int,
    subid_tran        int,
    rowset_id         bigint          not null,
    sec_version_rid   binary(8)       not null,
    min_len           smallint,
    seq_num           bigint,
    prev_row_in_chain binary(8)       not null,
    row_version       varbinary(8000) not null
)
go

create table sys.plan_persist_context_settings
(
    context_settings_id       bigint   not null,
    set_options               int      not null,
    language_id               smallint not null,
    date_format               smallint not null,
    date_first                tinyint  not null,
    compatibility_level       smallint not null,
    status                    smallint not null,
    required_cursor_options   int      not null,
    acceptable_cursor_options int      not null,
    merge_action_type         smallint not null,
    default_schema_id         int      not null,
    is_replication_specific   bit      not null,
    status2                   tinyint  not null
)
go

create unique clustered index plan_persist_context_settings_cidx
    on sys.plan_persist_context_settings (context_settings_id desc)
go

create table sys.plan_persist_plan
(
    plan_id                    bigint         not null,
    query_id                   bigint         not null,
    plan_group_id              bigint,
    engine_version             bigint         not null,
    query_plan_hash            binary(8)      not null,
    query_plan                 varbinary(max),
    is_online_index_plan       bit            not null,
    is_trivial_plan            bit            not null,
    is_parallel_plan           bit            not null,
    is_forced_plan             bit            not null,
    force_failure_count        bigint         not null,
    last_force_failure_reason  int            not null,
    count_compiles             bigint         not null,
    initial_compile_start_time datetimeoffset not null,
    last_compile_start_time    datetimeoffset not null,
    last_execution_time        datetimeoffset,
    total_compile_duration     bigint         not null,
    last_compile_duration      bigint         not null,
    compatibility_level        smallint       not null,
    plan_flags                 int
)
go

create unique clustered index plan_persist_plan_cidx
    on sys.plan_persist_plan (plan_id)
go

create index plan_persist_plan_idx1
    on sys.plan_persist_plan (query_id desc)
go

create table sys.plan_persist_plan_feedback
(
    plan_feedback_id  bigint         not null,
    plan_id           bigint         not null,
    feature_id        tinyint        not null,
    feedback_data     varbinary(max),
    state             int            not null,
    create_time       datetimeoffset not null,
    last_updated_time datetimeoffset,
    replica_group_id  bigint         not null
)
go

create unique clustered index plan_feedback_cidx
    on sys.plan_persist_plan_feedback (plan_feedback_id)
go

create index plan_feedback_idx1
    on sys.plan_persist_plan_feedback (plan_id, feature_id)
go

create table sys.plan_persist_plan_forcing_locations
(
    plan_forcing_location_id bigint   not null,
    query_id                 bigint   not null,
    plan_id                  bigint   not null,
    replica_group_id         bigint   not null,
    timestamp                datetime not null,
    plan_forcing_flags       int      not null
)
go

create unique clustered index plan_persist_plan_force_cidx
    on sys.plan_persist_plan_forcing_locations (query_id, plan_id, replica_group_id)
go

create unique index plan_persist_plan_force_idx1
    on sys.plan_persist_plan_forcing_locations (plan_forcing_location_id desc)
go

create table sys.plan_persist_query
(
    query_id                        bigint         not null,
    query_text_id                   bigint         not null,
    context_settings_id             bigint         not null,
    object_id                       bigint,
    batch_sql_handle                varbinary(64),
    query_hash                      binary(8)      not null,
    is_internal_query               bit            not null,
    query_param_type                tinyint        not null,
    initial_compile_start_time      datetimeoffset not null,
    last_compile_start_time         datetimeoffset not null,
    last_execution_time             datetimeoffset,
    last_compile_batch_sql_handle   varbinary(64),
    last_compile_batch_offset_start bigint         not null,
    last_compile_batch_offset_end   bigint         not null,
    compile_count                   bigint         not null,
    total_compile_duration          bigint         not null,
    last_compile_duration           bigint         not null,
    total_parse_duration            bigint         not null,
    last_parse_duration             bigint         not null,
    total_parse_cpu_time            bigint         not null,
    last_parse_cpu_time             bigint         not null,
    total_bind_duration             bigint         not null,
    last_bind_duration              bigint         not null,
    total_bind_cpu_time             bigint         not null,
    last_bind_cpu_time              bigint         not null,
    total_optimize_duration         bigint         not null,
    last_optimize_duration          bigint         not null,
    total_optimize_cpu_time         bigint         not null,
    last_optimize_cpu_time          bigint         not null,
    total_compile_memory_kb         bigint         not null,
    last_compile_memory_kb          bigint         not null,
    max_compile_memory_kb           bigint         not null,
    status                          tinyint        not null,
    statement_sql_handle            varbinary(64),
    query_flags                     int
)
go

create unique clustered index plan_persist_query_cidx
    on sys.plan_persist_query (query_id)
go

create index plan_persist_query_idx1
    on sys.plan_persist_query (query_text_id, context_settings_id)
go

create table sys.plan_persist_query_hints
(
    query_hint_id                  bigint        not null,
    query_id                       bigint        not null,
    context_settings_id            bigint        not null,
    object_id                      bigint,
    statement_sql_handle           varbinary(64) not null,
    query_param_type               tinyint       not null,
    batch_sql_handle               varbinary(64),
    query_hash                     binary(8)     not null,
    query_hints                    nvarchar(max),
    query_hints_flags              int,
    last_query_hint_failure_reason int           not null,
    query_hint_failure_count       bigint        not null,
    comment                        nvarchar(max),
    replica_group_id               bigint        not null
)
go

create unique clustered index plan_persist_query_hints_cidx
    on sys.plan_persist_query_hints (query_hint_id)
go

create index plan_persist_query_hints_idx1
    on sys.plan_persist_query_hints (query_id)
go

create table sys.plan_persist_query_template_parameterization
(
    query_template_id                    bigint        not null,
    query_template                       nvarchar(max),
    query_template_hash                  varbinary(16) not null,
    query_param_type                     tinyint       not null,
    query_template_flags                 int,
    status                               tinyint       not null,
    last_parameterization_failure_reason int           not null,
    parameterization_failure_count       bigint        not null,
    comment                              nvarchar(max)
)
go

create unique clustered index plan_persist_query_template_parameterization_cidx
    on sys.plan_persist_query_template_parameterization (query_template_id)
go

create unique index plan_persist_query_template_parameterization_idx1
    on sys.plan_persist_query_template_parameterization (query_template_hash)
go

create table sys.plan_persist_query_text
(
    query_text_id               bigint        not null,
    query_sql_text              nvarchar(max),
    statement_sql_handle        varbinary(64) not null,
    is_part_of_encrypted_module bit           not null,
    has_restricted_text         bit           not null,
    query_template_hash         varbinary(16)
)
go

create unique clustered index plan_persist_query_text_cidx
    on sys.plan_persist_query_text (query_text_id)
go

create unique index plan_persist_query_text_idx1
    on sys.plan_persist_query_text (statement_sql_handle)
go

create table sys.plan_persist_query_variant
(
    query_variant_query_id bigint not null,
    parent_query_id        bigint not null,
    dispatcher_plan_id     bigint not null
)
go

create unique clustered index plan_persist_query_variant_cidx
    on sys.plan_persist_query_variant (query_variant_query_id)
go

create index plan_persist_query_variant_idx1
    on sys.plan_persist_query_variant (parent_query_id, dispatcher_plan_id)
go

create table sys.plan_persist_replicas
(
    replica_group_id bigint   not null,
    role_type        smallint not null,
    replica_name     nvarchar(644)
)
go

create unique clustered index plan_persist_qds_replicas_cidx
    on sys.plan_persist_replicas (replica_group_id)
go

create index plan_persist_qds_replicas_idx1
    on sys.plan_persist_replicas (role_type)
go

create table sys.plan_persist_runtime_stats
(
    runtime_stats_id                bigint         not null,
    plan_id                         bigint         not null,
    runtime_stats_interval_id       bigint         not null,
    execution_type                  tinyint        not null,
    first_execution_time            datetimeoffset not null,
    last_execution_time             datetimeoffset not null,
    count_executions                bigint         not null,
    total_duration                  bigint         not null,
    last_duration                   bigint         not null,
    min_duration                    bigint         not null,
    max_duration                    bigint         not null,
    sumsquare_duration              float          not null,
    total_cpu_time                  bigint         not null,
    last_cpu_time                   bigint         not null,
    min_cpu_time                    bigint         not null,
    max_cpu_time                    bigint         not null,
    sumsquare_cpu_time              float          not null,
    total_logical_io_reads          bigint         not null,
    last_logical_io_reads           bigint         not null,
    min_logical_io_reads            bigint         not null,
    max_logical_io_reads            bigint         not null,
    sumsquare_logical_io_reads      float          not null,
    total_logical_io_writes         bigint         not null,
    last_logical_io_writes          bigint         not null,
    min_logical_io_writes           bigint         not null,
    max_logical_io_writes           bigint         not null,
    sumsquare_logical_io_writes     float          not null,
    total_physical_io_reads         bigint         not null,
    last_physical_io_reads          bigint         not null,
    min_physical_io_reads           bigint         not null,
    max_physical_io_reads           bigint         not null,
    sumsquare_physical_io_reads     float          not null,
    total_clr_time                  bigint         not null,
    last_clr_time                   bigint         not null,
    min_clr_time                    bigint         not null,
    max_clr_time                    bigint         not null,
    sumsquare_clr_time              float          not null,
    total_dop                       bigint         not null,
    last_dop                        bigint         not null,
    min_dop                         bigint         not null,
    max_dop                         bigint         not null,
    sumsquare_dop                   float          not null,
    total_query_max_used_memory     bigint         not null,
    last_query_max_used_memory      bigint         not null,
    min_query_max_used_memory       bigint         not null,
    max_query_max_used_memory       bigint         not null,
    sumsquare_query_max_used_memory float          not null,
    total_rowcount                  bigint         not null,
    last_rowcount                   bigint         not null,
    min_rowcount                    bigint         not null,
    max_rowcount                    bigint         not null,
    sumsquare_rowcount              float          not null,
    total_num_physical_io_reads     bigint,
    last_num_physical_io_reads      bigint,
    min_num_physical_io_reads       bigint,
    max_num_physical_io_reads       bigint,
    sumsquare_num_physical_io_reads float,
    total_log_bytes_used            bigint,
    last_log_bytes_used             bigint,
    min_log_bytes_used              bigint,
    max_log_bytes_used              bigint,
    sumsquare_log_bytes_used        float,
    total_tempdb_space_used         bigint,
    last_tempdb_space_used          bigint,
    min_tempdb_space_used           bigint,
    max_tempdb_space_used           bigint,
    sumsquare_tempdb_space_used     float,
    total_page_server_io_reads      bigint,
    last_page_server_io_reads       bigint,
    min_page_server_io_reads        bigint,
    max_page_server_io_reads        bigint,
    sumsquare_page_server_io_reads  float
)
go

create unique clustered index plan_persist_runtime_stats_cidx
    on sys.plan_persist_runtime_stats (plan_id, runtime_stats_interval_id, execution_type)
go

create unique index plan_persist_runtime_stats_idx1
    on sys.plan_persist_runtime_stats (runtime_stats_id)
go

create table sys.plan_persist_runtime_stats_interval
(
    runtime_stats_interval_id bigint         not null,
    start_time                datetimeoffset not null,
    end_time                  datetimeoffset not null,
    comment                   nvarchar(max)
)
go

create unique clustered index plan_persist_runtime_stats_interval_cidx
    on sys.plan_persist_runtime_stats_interval (runtime_stats_interval_id)
go

create index plan_persist_runtime_stats_interval_idx1
    on sys.plan_persist_runtime_stats_interval (end_time)
go

create table sys.plan_persist_runtime_stats_v2
(
    runtime_stats_id                bigint         not null,
    plan_id                         bigint         not null,
    runtime_stats_interval_id       bigint         not null,
    execution_type                  tinyint        not null,
    first_execution_time            datetimeoffset not null,
    last_execution_time             datetimeoffset not null,
    count_executions                bigint         not null,
    total_duration                  bigint         not null,
    last_duration                   bigint         not null,
    min_duration                    bigint         not null,
    max_duration                    bigint         not null,
    sumsquare_duration              float          not null,
    total_cpu_time                  bigint         not null,
    last_cpu_time                   bigint         not null,
    min_cpu_time                    bigint         not null,
    max_cpu_time                    bigint         not null,
    sumsquare_cpu_time              float          not null,
    total_logical_io_reads          bigint         not null,
    last_logical_io_reads           bigint         not null,
    min_logical_io_reads            bigint         not null,
    max_logical_io_reads            bigint         not null,
    sumsquare_logical_io_reads      float          not null,
    total_logical_io_writes         bigint         not null,
    last_logical_io_writes          bigint         not null,
    min_logical_io_writes           bigint         not null,
    max_logical_io_writes           bigint         not null,
    sumsquare_logical_io_writes     float          not null,
    total_physical_io_reads         bigint         not null,
    last_physical_io_reads          bigint         not null,
    min_physical_io_reads           bigint         not null,
    max_physical_io_reads           bigint         not null,
    sumsquare_physical_io_reads     float          not null,
    total_clr_time                  bigint         not null,
    last_clr_time                   bigint         not null,
    min_clr_time                    bigint         not null,
    max_clr_time                    bigint         not null,
    sumsquare_clr_time              float          not null,
    total_dop                       bigint         not null,
    last_dop                        bigint         not null,
    min_dop                         bigint         not null,
    max_dop                         bigint         not null,
    sumsquare_dop                   float          not null,
    total_query_max_used_memory     bigint         not null,
    last_query_max_used_memory      bigint         not null,
    min_query_max_used_memory       bigint         not null,
    max_query_max_used_memory       bigint         not null,
    sumsquare_query_max_used_memory float          not null,
    total_rowcount                  bigint         not null,
    last_rowcount                   bigint         not null,
    min_rowcount                    bigint         not null,
    max_rowcount                    bigint         not null,
    sumsquare_rowcount              float          not null,
    total_num_physical_io_reads     bigint,
    last_num_physical_io_reads      bigint,
    min_num_physical_io_reads       bigint,
    max_num_physical_io_reads       bigint,
    sumsquare_num_physical_io_reads float,
    total_log_bytes_used            bigint,
    last_log_bytes_used             bigint,
    min_log_bytes_used              bigint,
    max_log_bytes_used              bigint,
    sumsquare_log_bytes_used        float,
    total_tempdb_space_used         bigint,
    last_tempdb_space_used          bigint,
    min_tempdb_space_used           bigint,
    max_tempdb_space_used           bigint,
    sumsquare_tempdb_space_used     float,
    total_page_server_io_reads      bigint,
    last_page_server_io_reads       bigint,
    min_page_server_io_reads        bigint,
    max_page_server_io_reads        bigint,
    sumsquare_page_server_io_reads  float,
    replica_group_id                bigint         not null
)
go

create unique clustered index plan_persist_runtime_stats_v2_cidx
    on sys.plan_persist_runtime_stats_v2 (runtime_stats_interval_id, replica_group_id, plan_id, execution_type)
go

create index plan_persist_runtime_stats_v2_idx1
    on sys.plan_persist_runtime_stats_v2 (plan_id, runtime_stats_interval_id, execution_type)
go

create unique index plan_persist_runtime_stats_v2_idx2
    on sys.plan_persist_runtime_stats_v2 (runtime_stats_id)
go

create table sys.plan_persist_wait_stats
(
    wait_stats_id                bigint   not null,
    runtime_stats_interval_id    bigint   not null,
    plan_id                      bigint   not null,
    wait_category                smallint not null,
    execution_type               tinyint  not null,
    count_executions             bigint   not null,
    total_query_wait_time_ms     bigint   not null,
    last_query_wait_time_ms      bigint   not null,
    min_query_wait_time_ms       bigint   not null,
    max_query_wait_time_ms       bigint   not null,
    sumsquare_query_wait_time_ms float    not null
)
go

create unique clustered index plan_persist_wait_stats_cidx
    on sys.plan_persist_wait_stats (runtime_stats_interval_id, plan_id, wait_category, execution_type)
go

create unique index plan_persist_wait_stats_idx1
    on sys.plan_persist_wait_stats (wait_stats_id)
go

create table sys.plan_persist_wait_stats_v2
(
    wait_stats_id                bigint   not null,
    runtime_stats_interval_id    bigint   not null,
    plan_id                      bigint   not null,
    wait_category                smallint not null,
    execution_type               tinyint  not null,
    count_executions             bigint   not null,
    total_query_wait_time_ms     bigint   not null,
    last_query_wait_time_ms      bigint   not null,
    min_query_wait_time_ms       bigint   not null,
    max_query_wait_time_ms       bigint   not null,
    sumsquare_query_wait_time_ms float    not null,
    replica_group_id             bigint   not null
)
go

create unique clustered index plan_persist_wait_stats_v2_cidx
    on sys.plan_persist_wait_stats_v2 (runtime_stats_interval_id, replica_group_id, plan_id, execution_type,
                                       wait_category)
go

create index plan_persist_wait_stats_v2_idx1
    on sys.plan_persist_wait_stats_v2 (plan_id, runtime_stats_interval_id, execution_type, wait_category)
go

create unique index plan_persist_wait_stats_v2_idx2
    on sys.plan_persist_wait_stats_v2 (wait_stats_id)
go

create table sys.queue_messages_1977058079
(
    status                  tinyint          not null,
    priority                tinyint          not null,
    queuing_order           bigint identity (0, 1),
    conversation_group_id   uniqueidentifier not null,
    conversation_handle     uniqueidentifier not null,
    message_sequence_number bigint           not null,
    message_id              uniqueidentifier not null,
    message_type_id         int              not null,
    service_id              int              not null,
    service_contract_id     int              not null,
    validation              nchar            not null collate Latin1_General_BIN,
    next_fragment           int              not null,
    fragment_size           int              not null,
    fragment_bitmap         bigint           not null,
    binary_message_body     varbinary(max),
    message_enqueue_time    datetime
)
go

create unique clustered index queue_clustered_index
    on sys.queue_messages_1977058079 (status, conversation_group_id, priority, conversation_handle, queuing_order)
go

create unique index queue_secondary_index
    on sys.queue_messages_1977058079 (status, priority, queuing_order, conversation_group_id, conversation_handle,
                                      service_id)
    with (allow_page_locks = OFF)
go

create table sys.queue_messages_2009058193
(
    status                  tinyint          not null,
    priority                tinyint          not null,
    queuing_order           bigint identity (0, 1),
    conversation_group_id   uniqueidentifier not null,
    conversation_handle     uniqueidentifier not null,
    message_sequence_number bigint           not null,
    message_id              uniqueidentifier not null,
    message_type_id         int              not null,
    service_id              int              not null,
    service_contract_id     int              not null,
    validation              nchar            not null collate Latin1_General_BIN,
    next_fragment           int              not null,
    fragment_size           int              not null,
    fragment_bitmap         bigint           not null,
    binary_message_body     varbinary(max),
    message_enqueue_time    datetime
)
go

create unique clustered index queue_clustered_index
    on sys.queue_messages_2009058193 (status, conversation_group_id, priority, conversation_handle, queuing_order)
go

create unique index queue_secondary_index
    on sys.queue_messages_2009058193 (status, priority, queuing_order, conversation_group_id, conversation_handle,
                                      service_id)
    with (allow_page_locks = OFF)
go

create table sys.queue_messages_2041058307
(
    status                  tinyint          not null,
    priority                tinyint          not null,
    queuing_order           bigint identity (0, 1),
    conversation_group_id   uniqueidentifier not null,
    conversation_handle     uniqueidentifier not null,
    message_sequence_number bigint           not null,
    message_id              uniqueidentifier not null,
    message_type_id         int              not null,
    service_id              int              not null,
    service_contract_id     int              not null,
    validation              nchar            not null collate Latin1_General_BIN,
    next_fragment           int              not null,
    fragment_size           int              not null,
    fragment_bitmap         bigint           not null,
    binary_message_body     varbinary(max),
    message_enqueue_time    datetime
)
go

create unique clustered index queue_clustered_index
    on sys.queue_messages_2041058307 (status, conversation_group_id, priority, conversation_handle, queuing_order)
go

create unique index queue_secondary_index
    on sys.queue_messages_2041058307 (status, priority, queuing_order, conversation_group_id, conversation_handle,
                                      service_id)
    with (allow_page_locks = OFF)
go

create table sys.sqlagent_job_history
(
    instance_id         int identity,
    job_id              uniqueidentifier not null,
    step_id             int              not null,
    sql_message_id      int              not null,
    sql_severity        int              not null,
    message             nvarchar(4000),
    run_status          int              not null,
    run_date            int              not null,
    run_time            int              not null,
    run_duration        int              not null,
    operator_id_emailed int              not null,
    operator_id_paged   int              not null,
    retries_attempted   int              not null
)
go

create unique clustered index sqlagent_job_history_clust
    on sys.sqlagent_job_history (instance_id)
go

create index sqlagent_job_history_nc1
    on sys.sqlagent_job_history (job_id)
go

create table sys.sqlagent_jobs
(
    job_id                uniqueidentifier not null,
    name                  sysname          not null,
    enabled               bit              not null,
    description           nvarchar(512),
    start_step_id         int              not null,
    notify_level_eventlog bit              not null,
    delete_level          int              not null,
    date_created          datetime         not null,
    date_modified         datetime         not null
)
go

create unique clustered index sqlagent_jobs_clust
    on sys.sqlagent_jobs (job_id)
go

create index sqlagent_jobs_nc1_name
    on sys.sqlagent_jobs (name)
go

create table sys.sqlagent_jobsteps
(
    job_id                uniqueidentifier not null,
    step_id               int              not null,
    step_name             sysname          not null,
    subsystem             nvarchar(40)     not null,
    command               nvarchar(max),
    flags                 int              not null,
    additional_parameters nvarchar(max),
    cmdexec_success_code  int              not null,
    on_success_action     tinyint          not null,
    on_success_step_id    int              not null,
    on_fail_action        tinyint          not null,
    on_fail_step_id       int              not null,
    server                sysname,
    database_name         sysname,
    database_user_name    sysname,
    retry_attempts        int              not null,
    retry_interval        int              not null,
    os_run_priority       int              not null,
    output_file_name      nvarchar(200),
    last_run_outcome      int              not null,
    last_run_duration     int              not null,
    last_run_retries      int              not null,
    last_run_date         int              not null,
    last_run_time         int              not null,
    step_uid              uniqueidentifier not null
)
go

create unique clustered index sqlagent_jobsteps_clust
    on sys.sqlagent_jobsteps (job_id, step_id)
go

create unique index sqlagent_jobsteps_nc1
    on sys.sqlagent_jobsteps (job_id, step_name)
go

create unique index sqlagent_jobsteps_nc2
    on sys.sqlagent_jobsteps (step_uid)
go

create table sys.sqlagent_jobsteps_logs
(
    log_id       int identity,
    log_text     nvarchar(max)    not null,
    date_created datetime         not null,
    step_uid     uniqueidentifier not null
)
go

create index sqlagent_jobsteps_logs_nc1
    on sys.sqlagent_jobsteps_logs (step_uid, date_created)
go

create table sys.sysallocunits
(
    auid       bigint    not null,
    type       tinyint   not null,
    ownerid    bigint    not null,
    status     int       not null,
    fgid       smallint  not null,
    pgfirst    binary(6) not null,
    pgroot     binary(6) not null,
    pgfirstiam binary(6) not null,
    pcused     bigint    not null,
    pcdata     bigint    not null,
    pcreserved bigint    not null
)
go

create unique clustered index clust
    on sys.sysallocunits (auid)
go

create unique index nc
    on sys.sysallocunits (ownerid, type, auid)
go

create table sys.sysasymkeys
(
    id         int            not null,
    name       sysname        not null,
    thumbprint varbinary(64)  not null,
    bitlength  int            not null,
    algorithm  char(2)        not null collate Latin1_General_CI_AS_KS_WS,
    modified   datetime       not null,
    pkey       varbinary(4700),
    encrtype   char(2)        not null collate Latin1_General_CI_AS_KS_WS,
    pukey      varbinary(max) not null
)
go

create unique clustered index cl
    on sys.sysasymkeys (id)
go

create unique index nc1
    on sys.sysasymkeys (name)
go

create unique index nc3
    on sys.sysasymkeys (thumbprint)
go

create table sys.sysaudacts
(
    class         tinyint not null,
    id            int     not null,
    subid         int     not null,
    grantee       int     not null,
    audit_spec_id int     not null,
    type          char(4) not null collate Latin1_General_CI_AS_KS_WS,
    state         char    not null collate Latin1_General_CI_AS_KS_WS
)
go

create unique clustered index clust
    on sys.sysaudacts (class, id, subid, grantee, audit_spec_id, type)
go

create table sys.sysbinobjs
(
    class    tinyint  not null,
    id       int      not null,
    nsid     int      not null,
    name     sysname  not null collate Latin1_General_BIN,
    status   int      not null,
    type     char(2)  not null collate Latin1_General_BIN,
    intprop  int      not null,
    created  datetime not null,
    modified datetime not null
)
go

create unique clustered index clst
    on sys.sysbinobjs (class, id)
go

create unique index nc1
    on sys.sysbinobjs (class, nsid, name)
go

create table sys.sysbinsubobjs
(
    class   tinyint not null,
    idmajor int     not null,
    subid   int     not null,
    name    sysname not null collate Latin1_General_BIN,
    status  int     not null,
    intprop int     not null
)
go

create unique clustered index clst
    on sys.sysbinsubobjs (class, idmajor, subid)
go

create unique index nc1
    on sys.sysbinsubobjs (name, idmajor, class)
go

create table sys.sysbrickfiles
(
    brickid           int           not null,
    dbid              int           not null,
    pruid             int           not null,
    fileid            int           not null,
    grpid             int           not null,
    status            int           not null,
    filetype          tinyint       not null,
    filestate         tinyint       not null,
    size              int           not null,
    maxsize           int           not null,
    growth            int           not null,
    lname             sysname       not null,
    pname             nvarchar(260) not null,
    createlsn         binary(10),
    droplsn           binary(10),
    fileguid          uniqueidentifier,
    internalstatus    int           not null,
    readonlylsn       binary(10),
    readwritelsn      binary(10),
    readonlybaselsn   binary(10),
    firstupdatelsn    binary(10),
    lastupdatelsn     binary(10),
    backuplsn         binary(10),
    diffbaselsn       binary(10),
    diffbaseguid      uniqueidentifier,
    diffbasetime      datetime      not null,
    diffbaseseclsn    binary(10),
    redostartlsn      binary(10),
    redotargetlsn     binary(10),
    forkguid          uniqueidentifier,
    forklsn           binary(10),
    forkvc            bigint        not null,
    redostartforkguid uniqueidentifier
)
go

create unique clustered index clst
    on sys.sysbrickfiles (dbid, pruid, fileid)
go

create table sys.syscerts
(
    id             int            not null,
    name           sysname        not null,
    issuer         varbinary(884) not null,
    snum           varbinary(32)  not null,
    thumbprint     varbinary(64)  not null,
    pkey           varbinary(4700),
    encrtype       char(2)        not null collate Latin1_General_CI_AS_KS_WS,
    cert           varbinary(max) not null,
    status         int            not null,
    lastpkeybackup datetime
)
go

create unique clustered index cl
    on sys.syscerts (id)
go

create unique index nc1
    on sys.syscerts (name)
go

create unique index nc2
    on sys.syscerts (issuer, snum)
go

create unique index nc3
    on sys.syscerts (thumbprint)
go

create table sys.syschildinsts
(
    lsid      varbinary(85) not null,
    iname     sysname       not null,
    ipipename nvarchar(260) not null,
    pid       int           not null,
    status    int           not null,
    crdate    datetime      not null,
    modate    datetime      not null,
    sysdbpath nvarchar(260) not null
)
go

create unique clustered index cl
    on sys.syschildinsts (lsid)
go

create table sys.sysclones
(
    id       int    not null,
    subid    int    not null,
    partid   int    not null,
    version  int    not null,
    segid    int    not null,
    cloneid  int    not null,
    rowsetid bigint not null,
    dbfragid int    not null,
    status   int    not null
)
go

create unique clustered index clst
    on sys.sysclones (id, subid, partid, version, segid, cloneid)
go

create table sys.sysclsobjs
(
    class    tinyint  not null,
    id       int      not null,
    name     sysname  not null,
    status   int      not null,
    type     char(2)  not null collate Latin1_General_CI_AS_KS_WS,
    intprop  int      not null,
    created  datetime not null,
    modified datetime not null
)
go

create unique clustered index clst
    on sys.sysclsobjs (class, id)
go

create unique index nc
    on sys.sysclsobjs (name, class)
go

create table sys.syscolpars
(
    id          int      not null,
    number      smallint not null,
    colid       int      not null,
    name        sysname,
    xtype       tinyint  not null,
    utype       int      not null,
    length      smallint not null,
    prec        tinyint  not null,
    scale       tinyint  not null,
    collationid int      not null,
    status      int      not null,
    maxinrow    smallint not null,
    xmlns       int      not null,
    dflt        int      not null,
    chk         int      not null,
    idtval      varbinary(64)
)
go

create unique clustered index clst
    on sys.syscolpars (id, number, colid)
go

create unique index nc
    on sys.syscolpars (id, name, number)
go

create table sys.syscommittab
(
    commit_ts   bigint   not null,
    xdes_id     bigint   not null,
    commit_lbn  bigint   not null,
    commit_csn  bigint   not null,
    commit_time datetime not null,
    dbfragid    int      not null
)
go

create unique clustered index ci_commit_ts
    on sys.syscommittab (commit_ts, xdes_id)
go

create unique index si_xdes_id
    on sys.syscommittab (xdes_id) include (dbfragid)
go

create index si_commit_time_ts
    on sys.syscommittab (commit_time, commit_ts)
go

create table sys.syscompfragments
(
    cprelid   int       not null,
    fragid    int       not null,
    fragobjid int       not null,
    ts        binary(8) not null,
    status    int       not null,
    datasize  bigint    not null,
    itemcnt   bigint    not null,
    rowcnt    bigint    not null
)
go

create unique clustered index clst
    on sys.syscompfragments (cprelid, fragid)
go

create table sys.sysconvgroup
(
    id         uniqueidentifier not null,
    service_id int              not null,
    status     int              not null,
    refcount   int              not null
)
go

create unique clustered index clst
    on sys.sysconvgroup (id)
go

create table sys.syscscolsegments
(
    hobt_id                 bigint     not null,
    column_id               int        not null,
    segment_id              int        not null,
    version                 int        not null,
    encoding_type           int        not null,
    row_count               int        not null,
    status                  int        not null,
    base_id                 bigint     not null,
    magnitude               float      not null,
    primary_dictionary_id   int        not null,
    secondary_dictionary_id int        not null,
    min_data_id             bigint     not null,
    max_data_id             bigint     not null,
    null_value              bigint     not null,
    on_disk_size            bigint     not null,
    data_ptr                binary(16) not null,
    container_id            smallint,
    bloom_filter_md         bigint,
    bloom_filter_data_ptr   varbinary(16),
    collation_id            int,
    min_deep_data           varbinary(18),
    max_deep_data           varbinary(18)
)
go

create unique clustered index clust
    on sys.syscscolsegments (hobt_id, column_id, segment_id)
go

create table sys.syscsdictionaries
(
    hobt_id       bigint     not null,
    column_id     int        not null,
    dictionary_id int        not null,
    version       int        not null,
    type          int        not null,
    flags         bigint     not null,
    last_id       int        not null,
    entry_count   bigint     not null,
    on_disk_size  bigint     not null,
    data_ptr      binary(16) not null,
    container_id  smallint
)
go

create unique clustered index clust
    on sys.syscsdictionaries (hobt_id, column_id, dictionary_id)
go

create table sys.syscsrowgroups
(
    hobt_id           bigint not null,
    segment_id        int    not null,
    version           int    not null,
    ds_hobtid         bigint,
    row_count         int    not null,
    status            int    not null,
    flags             int    not null,
    compressed_reason int    not null,
    generation        bigint not null,
    created_time      datetime,
    closed_time       datetime,
    container_id      smallint,
    blob_id           binary(16),
    metadata_offset   int,
    metadata_size     int
)
go

create unique clustered index clust
    on sys.syscsrowgroups (hobt_id, segment_id)
go

create table sys.sysdbfiles
(
    dbfragid int              not null,
    fileid   int              not null,
    fileguid uniqueidentifier not null,
    pname    nvarchar(260)
)
go

create unique clustered index clst
    on sys.sysdbfiles (dbfragid, fileid)
go

create table sys.sysdbfrag
(
    dbid    int     not null,
    fragid  int     not null,
    name    sysname not null,
    brickid int     not null,
    pruid   int     not null,
    status  int     not null
)
go

create unique clustered index cl
    on sys.sysdbfrag (dbid, fragid)
go

create unique index nc1
    on sys.sysdbfrag (dbid, brickid, pruid)
go

create table sys.sysdbreg
(
    id          int              not null,
    name        sysname          not null,
    sid         varbinary(85),
    status      int              not null,
    status2     int              not null,
    category    int              not null,
    crdate      datetime         not null,
    modified    datetime         not null,
    svcbrkrguid uniqueidentifier not null,
    scope       int              not null,
    cmptlevel   tinyint          not null
)
go

create unique clustered index clst
    on sys.sysdbreg (id)
go

create unique index nc1
    on sys.sysdbreg (name)
go

create unique index nc2
    on sys.sysdbreg (svcbrkrguid, scope)
go

create table sys.sysdercv
(
    diagid       uniqueidentifier not null,
    initiator    tinyint          not null,
    handle       uniqueidentifier not null,
    rcvseq       bigint           not null,
    rcvfrag      int              not null,
    status       int              not null,
    state        char(2)          not null collate Latin1_General_CI_AS_KS_WS,
    lifetime     datetime         not null,
    contract     int              not null,
    svcid        int              not null,
    convgroup    uniqueidentifier not null,
    sysseq       bigint           not null,
    enddlgseq    bigint           not null,
    firstoorder  bigint           not null,
    lastoorder   bigint           not null,
    lastoorderfr int              not null,
    dlgtimer     datetime         not null,
    dlgopened    datetime         not null,
    princid      int              not null,
    outseskey    varbinary(4096)  not null,
    outseskeyid  uniqueidentifier not null,
    farprincid   int              not null,
    inseskey     varbinary(4096)  not null,
    inseskeyid   uniqueidentifier not null,
    farsvc       nvarchar(256)    not null collate Latin1_General_BIN,
    farbrkrinst  nvarchar(128) collate Latin1_General_BIN,
    priority     tinyint          not null
)
go

create unique clustered index cl
    on sys.sysdercv (diagid, initiator)
go

create table sys.sysdesend
(
    handle    uniqueidentifier not null,
    diagid    uniqueidentifier not null,
    initiator tinyint          not null,
    sendseq   bigint           not null,
    sendxact  binary(6)        not null
)
go

create unique clustered index cl
    on sys.sysdesend (handle)
go

create table sys.sysendpts
(
    id             int      not null,
    name           sysname  not null,
    protocol       tinyint  not null,
    type           tinyint  not null,
    bstat          smallint not null,
    affinity       bigint   not null,
    pstat          smallint not null,
    tstat          smallint not null,
    typeint        int      not null,
    port1          int      not null,
    port2          int      not null,
    site           nvarchar(128) collate Latin1_General_CI_AS_KS_WS,
    dfltns         nvarchar(384) collate Latin1_General_BIN,
    wsdlproc       nvarchar(776),
    dfltdb         sysname,
    authrealm      nvarchar(128),
    dfltdm         nvarchar(128),
    maxconn        int      not null,
    encalg         tinyint  not null,
    authtype       tinyint  not null,
    encryptiontype tinyint
)
go

create unique clustered index clst
    on sys.sysendpts (id)
go

create unique index nc1
    on sys.sysendpts (name)
go

create table sys.sysextfileformats
(
    file_format_id   int           not null,
    name             nvarchar(128) not null,
    format_type      nvarchar(100) not null,
    field_terminator nvarchar(10),
    string_delimiter nvarchar(10),
    date_format      nvarchar(50),
    use_type_default int           not null,
    serde_method     nvarchar(255),
    row_terminator   nvarchar(10),
    encoding         nvarchar(10),
    data_compression nvarchar(255),
    first_row        int,
    extractor        nvarchar(255),
    null_values      nvarchar(421),
    parser_version   nvarchar(8)
)
go

create unique clustered index clidx1
    on sys.sysextfileformats (file_format_id)
go

create unique index ncidx1
    on sys.sysextfileformats (name)
go

create table sys.sysextsources
(
    data_source_id       int            not null,
    name                 nvarchar(128)  not null,
    type_desc            nvarchar(255)  not null,
    type                 tinyint        not null,
    location             nvarchar(4000) not null,
    credential_id        int            not null,
    job_tracker_location nvarchar(4000),
    storage_key          nvarchar(4000),
    user_name            nvarchar(128),
    shard_map_manager_db nvarchar(128),
    shard_map_name       nvarchar(128),
    connection_options   nvarchar(4000),
    pushdown             nvarchar(256)  not null
)
go

create unique clustered index clidx1
    on sys.sysextsources (data_source_id)
go

create unique index ncidx1
    on sys.sysextsources (name)
go

create table sys.sysexttables
(
    object_id             int     not null,
    data_source_id        int     not null,
    file_format_id        int,
    location              nvarchar(4000),
    reject_type           nvarchar(20),
    reject_value          float,
    reject_sample_value   float,
    sharding_dist_type    tinyint not null,
    sharding_col_id       int     not null,
    source_schema_name    nvarchar(128),
    source_table_name     nvarchar(128),
    rejected_row_location nvarchar(4000)
)
go

create unique clustered index clidx1
    on sys.sysexttables (object_id)
go

create table sys.sysfgfrag
(
    fgid     int not null,
    fgfragid int not null,
    dbfragid int not null,
    phfgid   int not null,
    status   int not null
)
go

create unique clustered index cl
    on sys.sysfgfrag (fgid, fgfragid, dbfragid, phfgid)
go

create table sys.sysfiles1
(
    status   int        not null,
    fileid   smallint   not null,
    name     nchar(128) not null,
    filename nchar(260) not null
)
go

create table sys.sysfoqueues
(
    id      int        not null,
    lsn     binary(10) not null,
    epoch   int,
    csn     bigint,
    created datetime   not null
)
go

create unique clustered index clst
    on sys.sysfoqueues (id, lsn)
go

create table sys.sysfos
(
    id       int            not null,
    tgid     int            not null,
    low      varbinary(512) not null,
    high     varbinary(512),
    rowcnt   bigint,
    size     bigint,
    csn      bigint,
    epoch    int,
    status   char           not null,
    history  varbinary(6000),
    created  datetime       not null,
    modified datetime       not null
)
go

create unique clustered index clst
    on sys.sysfos (id)
go

create unique index nc1
    on sys.sysfos (tgid, low, high)
go

create table sys.sysftinds
(
    id                int       not null,
    indid             int       not null,
    status            int       not null,
    crtype            char      not null collate Latin1_General_CI_AS_KS_WS,
    crstart           datetime,
    crend             datetime,
    crrows            bigint    not null,
    crerrors          int       not null,
    crschver          binary(8) not null,
    crtsnext          binary(8),
    sensitivity       tinyint   not null,
    bXVTDocidUseBaseT tinyint   not null,
    batchsize         int       not null,
    nextdocid         bigint    not null,
    fgid              int       not null
)
go

create unique clustered index clst
    on sys.sysftinds (id)
go

create table sys.sysftproperties
(
    property_list_id   int              not null,
    property_id        int              not null,
    property_name      nvarchar(256)    not null collate SQL_Latin1_General_CP437_CS_AS,
    guid_identifier    uniqueidentifier not null,
    int_identifier     int              not null,
    string_description nvarchar(512)
)
go

create unique clustered index clst
    on sys.sysftproperties (property_list_id, property_id)
go

create unique index nonclst
    on sys.sysftproperties (property_list_id, property_name)
go

create unique index nonclstgi
    on sys.sysftproperties (property_list_id, guid_identifier, int_identifier)
go

create table sys.sysftsemanticsdb
(
    database_id   int              not null,
    register_date datetime         not null,
    registered_by int              not null,
    version       nvarchar(128)    not null,
    fileguid      uniqueidentifier not null
)
go

create unique clustered index cl
    on sys.sysftsemanticsdb (database_id)
go

create table sys.sysftstops
(
    stoplistid int          not null,
    stopword   nvarchar(64) not null collate Latin1_General_BIN,
    lcid       int          not null,
    status     tinyint      not null
)
go

create unique clustered index clst
    on sys.sysftstops (stoplistid, stopword, lcid)
go

create table sys.sysguidrefs
(
    class  tinyint          not null,
    id     int              not null,
    subid  int              not null,
    guid   uniqueidentifier not null,
    status int              not null
)
go

create unique clustered index cl
    on sys.sysguidrefs (id, class, subid)
go

create unique index nc
    on sys.sysguidrefs (guid, class)
go

create table sys.sysidxstats
(
    id        int     not null,
    indid     int     not null,
    name      sysname,
    status    int     not null,
    intprop   int     not null,
    fillfact  tinyint not null,
    type      tinyint not null,
    tinyprop  tinyint not null,
    dataspace int     not null,
    lobds     int     not null,
    rowset    bigint  not null
)
go

create unique clustered index clst
    on sys.sysidxstats (id, indid)
go

create unique index nc
    on sys.sysidxstats (name, id)
go

create table sys.sysiscols
(
    idmajor   int     not null,
    idminor   int     not null,
    subid     int     not null,
    status    int     not null,
    intprop   int     not null,
    tinyprop1 tinyint not null,
    tinyprop2 tinyint not null,
    tinyprop3 tinyint not null,
    tinyprop4 tinyint not null
)
go

create unique clustered index clst
    on sys.sysiscols (idmajor, idminor, subid)
go

create unique index nc1
    on sys.sysiscols (idmajor, intprop, subid, idminor)
go

create table sys.syslnklgns
(
    srvid   int      not null,
    lgnid   int,
    name    sysname,
    status  int      not null,
    modate  datetime not null,
    pwdhash varbinary(320)
)
go

create unique clustered index cl
    on sys.syslnklgns (srvid, lgnid)
go

create table sys.sysmultiobjrefs
(
    class      tinyint not null,
    depid      int     not null,
    depsubid   int     not null,
    indepid    int     not null,
    indepsubid int     not null,
    status     int     not null
)
go

create unique clustered index clst
    on sys.sysmultiobjrefs (depid, class, depsubid, indepid, indepsubid)
go

create unique index nc1
    on sys.sysmultiobjrefs (indepid, class, indepsubid, depid, depsubid)
go

create table sys.sysmultiobjvalues
(
    valclass   tinyint not null,
    depid      int     not null,
    depsubid   int     not null,
    indepid    int     not null,
    indepsubid int     not null,
    valnum     int     not null,
    value      sql_variant,
    imageval   varbinary(max)
)
go

create unique clustered index clust
    on sys.sysmultiobjvalues (valclass, depid, depsubid, indepid, indepsubid, valnum)
go

create unique index nc1
    on sys.sysmultiobjvalues (valclass, indepid, indepsubid, depid, depsubid, valnum)
go

create table sys.sysnsobjs
(
    class    tinyint  not null,
    id       int      not null,
    name     sysname  not null,
    nsid     int      not null,
    status   int      not null,
    intprop  int      not null,
    created  datetime not null,
    modified datetime not null
)
go

create unique clustered index clst
    on sys.sysnsobjs (class, id)
go

create unique index nc
    on sys.sysnsobjs (name, nsid, class)
go

create table sys.sysobjkeycrypts
(
    class      tinyint        not null,
    id         int            not null,
    thumbprint varbinary(32)  not null,
    type       char(4)        not null collate Latin1_General_CI_AS_KS_WS,
    crypto     varbinary(max) not null,
    status     int            not null
)
go

create unique clustered index cl
    on sys.sysobjkeycrypts (class, id, thumbprint)
go

create table sys.sysobjvalues
(
    valclass tinyint not null,
    objid    int     not null,
    subobjid int     not null,
    valnum   int     not null,
    value    sql_variant,
    imageval varbinary(max)
)
go

create unique clustered index clst
    on sys.sysobjvalues (valclass, objid, subobjid, valnum)
go

create table sys.sysowners
(
    id          int      not null,
    name        sysname  not null,
    type        char     not null collate Latin1_General_CI_AS_KS_WS,
    sid         varbinary(85),
    password    varbinary(256),
    dfltsch     sysname,
    status      int      not null,
    created     datetime not null,
    modified    datetime not null,
    deflanguage sysname,
    tenantid    uniqueidentifier,
    onpremsid   varbinary(85),
    externaloid uniqueidentifier
)
go

create unique clustered index clst
    on sys.sysowners (id)
go

create unique index nc1
    on sys.sysowners (name)
go

create unique index nc2
    on sys.sysowners (sid, id)
go

create table sys.sysphfg
(
    dbfragid int     not null,
    phfgid   int     not null,
    fgid     int     not null,
    type     char(2) not null collate Latin1_General_CI_AS_KS_WS,
    fgguid   uniqueidentifier,
    lgfgid   int,
    status   int     not null,
    name     sysname not null
)
go

create unique clustered index cl
    on sys.sysphfg (phfgid)
go

create table sys.syspriorities
(
    priority_id         int     not null,
    name                sysname not null,
    service_contract_id int,
    local_service_id    int,
    remote_service_name nvarchar(256),
    priority            tinyint not null
)
go

create unique clustered index cl
    on sys.syspriorities (priority_id)
go

create unique index nc
    on sys.syspriorities (service_contract_id, local_service_id, remote_service_name) include (priority)
go

create unique index nc2
    on sys.syspriorities (name)
go

create table sys.sysprivs
(
    class   tinyint not null,
    id      int     not null,
    subid   int     not null,
    grantee int     not null,
    grantor int     not null,
    type    char(4) not null collate Latin1_General_CI_AS_KS_WS,
    state   char    not null collate Latin1_General_CI_AS_KS_WS
)
go

create unique clustered index clust
    on sys.sysprivs (class, id, subid, grantee, grantor, type)
go

create table sys.syspru
(
    brickid int not null,
    dbid    int not null,
    pruid   int not null,
    fragid  int not null,
    status  int not null
)
go

create unique clustered index cl
    on sys.syspru (dbid, pruid)
go

create table sys.sysprufiles
(
    dbfragid          int           not null,
    fileid            int           not null,
    grpid             int           not null,
    status            int           not null,
    filetype          tinyint       not null,
    filestate         tinyint       not null,
    size              int           not null,
    maxsize           int           not null,
    growth            int           not null,
    lname             sysname       not null,
    pname             nvarchar(260) not null,
    createlsn         binary(10),
    droplsn           binary(10),
    fileguid          uniqueidentifier,
    internalstatus    int           not null,
    readonlylsn       binary(10),
    readwritelsn      binary(10),
    readonlybaselsn   binary(10),
    firstupdatelsn    binary(10),
    lastupdatelsn     binary(10),
    backuplsn         binary(10),
    diffbaselsn       binary(10),
    diffbaseguid      uniqueidentifier,
    diffbasetime      datetime      not null,
    diffbaseseclsn    binary(10),
    redostartlsn      binary(10),
    redotargetlsn     binary(10),
    forkguid          uniqueidentifier,
    forklsn           binary(10),
    forkvc            bigint        not null,
    redostartforkguid uniqueidentifier
)
go

create unique clustered index clst
    on sys.sysprufiles (fileid)
go

create table sys.sysqnames
(
    qid  int            not null,
    hash int            not null,
    nid  int            not null,
    name nvarchar(4000) not null collate Latin1_General_BIN
)
go

create unique clustered index clst
    on sys.sysqnames (qid, hash, nid)
go

create unique index nc1
    on sys.sysqnames (nid)
go

create table sys.sysremsvcbinds
(
    id     int     not null,
    name   sysname not null,
    scid   int     not null,
    remsvc nvarchar(256) collate Latin1_General_BIN,
    status int     not null
)
go

create unique clustered index clst
    on sys.sysremsvcbinds (id)
go

create unique index nc1
    on sys.sysremsvcbinds (name)
go

create unique index nc2
    on sys.sysremsvcbinds (scid, remsvc)
go

create table sys.sysrmtlgns
(
    srvid  int      not null,
    name   sysname,
    lgnid  int,
    status int      not null,
    modate datetime not null
)
go

create unique clustered index cl
    on sys.sysrmtlgns (srvid, name)
go

create table sys.sysrowsetrefs
(
    class     tinyint not null,
    objid     int     not null,
    indexid   int     not null,
    rowsetnum int     not null,
    rowsetid  bigint  not null,
    status    int     not null
)
go

create unique clustered index clust
    on sys.sysrowsetrefs (class, objid, indexid, rowsetnum)
go

create table sys.sysrowsets
(
    rowsetid   bigint   not null,
    ownertype  tinyint  not null,
    idmajor    int      not null,
    idminor    int      not null,
    numpart    int      not null,
    status     int      not null,
    fgidfs     smallint not null,
    rcrows     bigint   not null,
    cmprlevel  tinyint  not null,
    fillfact   tinyint  not null,
    maxnullbit smallint not null,
    maxleaf    int      not null,
    maxint     smallint not null,
    minleaf    smallint not null,
    minint     smallint not null,
    rsguid     varbinary(16),
    lockres    varbinary(8),
    scope_id   int
)
go

create unique clustered index clust
    on sys.sysrowsets (rowsetid)
go

create table sys.sysrscols
(
    rsid        bigint   not null,
    rscolid     int      not null,
    hbcolid     int      not null,
    rcmodified  bigint   not null,
    ti          int      not null,
    cid         int      not null,
    ordkey      smallint not null,
    maxinrowlen smallint not null,
    status      int      not null,
    offset      int      not null,
    nullbit     int      not null,
    bitpos      smallint not null,
    colguid     varbinary(16),
    ordlock     int
)
go

create unique clustered index clst
    on sys.sysrscols (rsid, hbcolid)
go

create table sys.sysrts
(
    id       int     not null,
    name     sysname not null,
    remsvc   nvarchar(256) collate Latin1_General_BIN,
    brkrinst nvarchar(128) collate Latin1_General_BIN,
    addr     nvarchar(256) collate Latin1_General_BIN,
    miraddr  nvarchar(256) collate Latin1_General_BIN,
    lifetime datetime
)
go

create unique clustered index clst
    on sys.sysrts (id)
go

create unique index nc1
    on sys.sysrts (remsvc, brkrinst, id)
go

create unique index nc2
    on sys.sysrts (name)
go

create table sys.sysscalartypes
(
    id          int      not null,
    schid       int      not null,
    name        sysname  not null,
    xtype       tinyint  not null,
    length      smallint not null,
    prec        tinyint  not null,
    scale       tinyint  not null,
    collationid int      not null,
    status      int      not null,
    created     datetime not null,
    modified    datetime not null,
    dflt        int      not null,
    chk         int      not null
)
go

create unique clustered index clst
    on sys.sysscalartypes (id)
go

create unique index nc1
    on sys.sysscalartypes (schid, name)
go

create unique index nc2
    on sys.sysscalartypes (name, schid)
go

create table sys.sysschobjs
(
    id       int      not null,
    name     sysname  not null,
    nsid     int      not null,
    nsclass  tinyint  not null,
    status   int      not null,
    type     char(2)  not null collate Latin1_General_CI_AS_KS_WS,
    pid      int      not null,
    pclass   tinyint  not null,
    intprop  int      not null,
    created  datetime not null,
    modified datetime not null,
    status2  int      not null
)
go

create unique clustered index clst
    on sys.sysschobjs (id)
go

create unique index nc1
    on sys.sysschobjs (nsclass, nsid, name)
go

create unique index nc2
    on sys.sysschobjs (name, nsid, nsclass)
go

create index nc3
    on sys.sysschobjs (pid, pclass)
go

create table sys.sysseobjvalues
(
    valclass tinyint not null,
    id       bigint  not null,
    subid    bigint  not null,
    valnum   int     not null,
    value    sql_variant,
    imageval varbinary(max)
)
go

create unique clustered index clst
    on sys.sysseobjvalues (valclass, id, subid, valnum)
go

create table sys.syssingleobjrefs
(
    class      tinyint not null,
    depid      int     not null,
    depsubid   int     not null,
    indepid    int     not null,
    indepsubid int     not null,
    status     int     not null
)
go

create unique clustered index clst
    on sys.syssingleobjrefs (depid, class, depsubid)
go

create unique index nc1
    on sys.syssingleobjrefs (indepid, class, indepsubid, depid, depsubid)
go

create table sys.syssoftobjrefs
(
    depclass    tinyint not null,
    depid       int     not null,
    indepclass  tinyint not null,
    indepname   sysname not null,
    indepschema sysname,
    indepdb     sysname,
    indepserver sysname,
    number      int     not null,
    status      int     not null
)
go

create unique clustered index clst
    on sys.syssoftobjrefs (depid, depclass, indepname, indepschema, indepclass, number)
go

create unique index nc1
    on sys.syssoftobjrefs (indepname, indepschema, indepclass, depid, depclass, number)
go

create table sys.syssqlguides
(
    id              int      not null,
    name            sysname  not null,
    scopetype       tinyint  not null,
    scopeid         int      not null,
    hash            varbinary(20),
    status          int      not null,
    created         datetime not null,
    modified        datetime not null,
    batchtext       nvarchar(max),
    paramorhinttext nvarchar(max)
)
go

create unique clustered index clst
    on sys.syssqlguides (id)
go

create unique index nc1
    on sys.syssqlguides (name)
go

create unique index nc2
    on sys.syssqlguides (scopetype, scopeid, hash, id)
go

create table sys.systypedsubobjs
(
    class       tinyint  not null,
    idmajor     int      not null,
    subid       int      not null,
    name        sysname collate Latin1_General_BIN,
    xtype       tinyint  not null,
    utype       int      not null,
    length      smallint not null,
    prec        tinyint  not null,
    scale       tinyint  not null,
    collationid int      not null,
    status      int      not null,
    intprop     int      not null
)
go

create unique clustered index clst
    on sys.systypedsubobjs (class, idmajor, subid)
go

create unique index nc
    on sys.systypedsubobjs (name, idmajor, class)
go

create table sys.sysusermsgs
(
    id        int            not null,
    msglangid smallint       not null,
    severity  smallint       not null,
    status    smallint       not null,
    text      nvarchar(1024) not null
)
go

create unique clustered index clst
    on sys.sysusermsgs (id, msglangid)
go

create table sys.syswebmethods
(
    id      int          not null,
    nmspace nvarchar(384) collate Latin1_General_BIN,
    alias   nvarchar(64) not null collate Latin1_General_BIN,
    objname nvarchar(776),
    status  int          not null
)
go

create unique clustered index clst
    on sys.syswebmethods (id, nmspace, alias)
go

create table sys.sysxlgns
(
    id          int      not null,
    name        sysname  not null,
    sid         varbinary(85),
    status      int      not null,
    type        char     not null collate Latin1_General_CI_AS_KS_WS,
    crdate      datetime not null,
    modate      datetime not null,
    dbname      sysname,
    lang        sysname,
    pwdhash     varbinary(256),
    tenantid    uniqueidentifier,
    onpremsid   varbinary(85),
    externaloid uniqueidentifier
)
go

create unique clustered index cl
    on sys.sysxlgns (id)
go

create unique index nc1
    on sys.sysxlgns (name)
go

create unique index nc2
    on sys.sysxlgns (sid)
go

create table sys.sysxmitbody
(
    msgref  bigint not null,
    count   int    not null,
    msgbody varbinary(max)
)
go

create unique clustered index clst
    on sys.sysxmitbody (msgref)
go

create table sys.sysxmitqueue
(
    dlgid        uniqueidentifier not null,
    finitiator   bit              not null,
    tosvc        nvarchar(256) collate Latin1_General_BIN,
    tobrkrinst   nvarchar(128) collate Latin1_General_BIN,
    fromsvc      nvarchar(256) collate Latin1_General_BIN,
    frombrkrinst nvarchar(128) collate Latin1_General_BIN,
    svccontr     nvarchar(256) collate Latin1_General_BIN,
    msgseqnum    bigint           not null,
    msgtype      nvarchar(256) collate Latin1_General_BIN,
    unackmfn     int              not null,
    status       int              not null,
    enqtime      datetime         not null,
    rsndtime     datetime,
    dlgerr       int              not null,
    msgid        uniqueidentifier not null,
    hdrpartlen   smallint         not null,
    hdrseclen    smallint         not null,
    msgenc       tinyint          not null,
    msgbodylen   int              not null,
    msgbody      varbinary(max),
    msgref       bigint
)
go

create unique clustered index clst
    on sys.sysxmitqueue (dlgid, finitiator, msgseqnum)
go

create table sys.sysxmlcomponent
(
    id       int     not null,
    xsdid    int     not null,
    uriord   int     not null,
    qual     tinyint not null,
    nameid   int     not null,
    symspace char    not null collate Latin1_General_BIN,
    nmscope  int     not null,
    kind     char    not null collate Latin1_General_BIN,
    deriv    char    not null collate Latin1_General_BIN,
    status   int     not null,
    enum     char    not null collate Latin1_General_BIN,
    defval   nvarchar(4000) collate Latin1_General_BIN
)
go

create unique clustered index cl
    on sys.sysxmlcomponent (id)
go

create unique index nc1
    on sys.sysxmlcomponent (xsdid, uriord, qual, nameid, symspace, nmscope)
go

create table sys.sysxmlfacet
(
    compid int      not null,
    ord    int      not null,
    kind   char(2)  not null collate Latin1_General_BIN,
    status smallint not null,
    dflt   nvarchar(4000) collate Latin1_General_BIN
)
go

create unique clustered index cl
    on sys.sysxmlfacet (compid, ord)
go

create table sys.sysxmlplacement
(
    placingid int not null,
    ordinal   int not null,
    placedid  int not null,
    status    int not null,
    minoccur  int not null,
    maxoccur  int not null,
    defval    nvarchar(4000) collate Latin1_General_BIN
)
go

create unique clustered index cl
    on sys.sysxmlplacement (placingid, ordinal)
go

create unique index nc1
    on sys.sysxmlplacement (placedid, placingid, ordinal)
go

create table sys.sysxprops
(
    class tinyint not null,
    id    int     not null,
    subid int     not null,
    name  sysname not null,
    value sql_variant
)
go

create unique clustered index clust
    on sys.sysxprops (class, id, subid, name)
go

create table sys.sysxsrvs
(
    id             int      not null,
    name           sysname  not null,
    product        sysname  not null,
    provider       sysname  not null,
    status         int      not null,
    modate         datetime not null,
    catalog        sysname,
    cid            int,
    connecttimeout int,
    querytimeout   int
)
go

create unique clustered index cl
    on sys.sysxsrvs (id)
go

create unique index nc1
    on sys.sysxsrvs (name)
go

create table sys.trace_xe_action_map
(
    trace_column_id smallint     not null,
    package_name    nvarchar(60) not null,
    xe_action_name  nvarchar(60) not null
)
go

create table sys.trace_xe_event_map
(
    trace_event_id smallint     not null,
    package_name   nvarchar(60) not null,
    xe_event_name  nvarchar(60) not null
)
go

create table sys.wpr_bucket_table
(
    bucket_id   bigint not null,
    bucket_data varbinary(8000)
)
go

create unique clustered index wpr_bucket_clustered_idx
    on sys.wpr_bucket_table (bucket_id)
go

create view INFORMATION_SCHEMA.CHECK_CONSTRAINTS as
-- missing source code
go

create view INFORMATION_SCHEMA.COLUMNS as
-- missing source code
go

create view INFORMATION_SCHEMA.COLUMN_DOMAIN_USAGE as
-- missing source code
go

create view INFORMATION_SCHEMA.COLUMN_PRIVILEGES as
-- missing source code
go

create view INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE as
-- missing source code
go

create view INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE as
-- missing source code
go

create view INFORMATION_SCHEMA.DOMAINS as
-- missing source code
go

create view INFORMATION_SCHEMA.DOMAIN_CONSTRAINTS as
-- missing source code
go

create view INFORMATION_SCHEMA.KEY_COLUMN_USAGE as
-- missing source code
go

create view INFORMATION_SCHEMA.PARAMETERS as
-- missing source code
go

create view INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS as
-- missing source code
go

create view INFORMATION_SCHEMA.ROUTINES as
-- missing source code
go

create view INFORMATION_SCHEMA.ROUTINE_COLUMNS as
-- missing source code
go

create view INFORMATION_SCHEMA.SCHEMATA as
-- missing source code
go

create view INFORMATION_SCHEMA.SEQUENCES as
-- missing source code
go

create view INFORMATION_SCHEMA.TABLES as
-- missing source code
go

create view INFORMATION_SCHEMA.TABLE_CONSTRAINTS as
-- missing source code
go

create view INFORMATION_SCHEMA.TABLE_PRIVILEGES as
-- missing source code
go

create view INFORMATION_SCHEMA.VIEWS as
-- missing source code
go

create view INFORMATION_SCHEMA.VIEW_COLUMN_USAGE as
-- missing source code
go

create view INFORMATION_SCHEMA.VIEW_TABLE_USAGE as
-- missing source code
go

create view sys.all_columns as
-- missing source code
go

create view sys.all_objects as
-- missing source code
go

create view sys.all_parameters as
-- missing source code
go

create view sys.all_sql_modules as
-- missing source code
go

create view sys.all_views as
-- missing source code
go

create view sys.allocation_units as
-- missing source code
go

create view sys.assemblies as
-- missing source code
go

create view sys.assembly_files as
-- missing source code
go

create view sys.assembly_modules as
-- missing source code
go

create view sys.assembly_references as
-- missing source code
go

create view sys.assembly_types as
-- missing source code
go

create view sys.asymmetric_keys as
-- missing source code
go

create view sys.availability_databases_cluster as
-- missing source code
go

create view sys.availability_group_listener_ip_addresses as
-- missing source code
go

create view sys.availability_group_listeners as
-- missing source code
go

create view sys.availability_groups as
-- missing source code
go

create view sys.availability_groups_cluster as
-- missing source code
go

create view sys.availability_read_only_routing_lists as
-- missing source code
go

create view sys.availability_replicas as
-- missing source code
go

create view sys.backup_devices as
-- missing source code
go

create view sys.certificates as
-- missing source code
go

create view sys.change_tracking_databases as
-- missing source code
go

create view sys.change_tracking_tables as
-- missing source code
go

create view sys.check_constraints as
-- missing source code
go

create view sys.column_encryption_key_values as
-- missing source code
go

create view sys.column_encryption_keys as
-- missing source code
go

create view sys.column_master_keys as
-- missing source code
go

create view sys.column_store_dictionaries as
-- missing source code
go

create view sys.column_store_row_groups as
-- missing source code
go

create view sys.column_store_segments as
-- missing source code
go

create view sys.column_type_usages as
-- missing source code
go

create view sys.column_xml_schema_collection_usages as
-- missing source code
go

create view sys.columns as
-- missing source code
go

create view sys.computed_columns as
-- missing source code
go

create view sys.configurations as
-- missing source code
go

create view sys.conversation_endpoints as
-- missing source code
go

create view sys.conversation_groups as
-- missing source code
go

create view sys.conversation_priorities as
-- missing source code
go

create view sys.credentials as
-- missing source code
go

create view sys.crypt_properties as
-- missing source code
go

create view sys.cryptographic_providers as
-- missing source code
go

create view sys.data_spaces as
-- missing source code
go

create view sys.database_audit_specification_details as
-- missing source code
go

create view sys.database_audit_specifications as
-- missing source code
go

create view sys.database_automatic_tuning_configurations as
-- missing source code
go

create view sys.database_automatic_tuning_mode as
-- missing source code
go

create view sys.database_automatic_tuning_options as
-- missing source code
go

create view sys.database_credentials as
-- missing source code
go

create view sys.database_files as
-- missing source code
go

create view sys.database_filestream_options as
-- missing source code
go

create view sys.database_ledger_blocks as
-- missing source code
go

create view sys.database_ledger_digest_locations as
-- missing source code
go

create view sys.database_ledger_transactions as
-- missing source code
go

create view sys.database_mirroring as
-- missing source code
go

create view sys.database_mirroring_endpoints as
-- missing source code
go

create view sys.database_mirroring_witnesses as
-- missing source code
go

create view sys.database_permissions as
-- missing source code
go

create view sys.database_principals as
-- missing source code
go

create view sys.database_query_store_internal_state as
-- missing source code
go

create view sys.database_query_store_options as
-- missing source code
go

create view sys.database_recovery_status as
-- missing source code
go

create view sys.database_role_members as
-- missing source code
go

create view sys.database_scoped_configurations as
-- missing source code
go

create view sys.database_scoped_credentials as
-- missing source code
go

create view sys.databases as
-- missing source code
go

create view sys.default_constraints as
-- missing source code
go

create view sys.destination_data_spaces as
-- missing source code
go

create view sys.dm_audit_actions as
-- missing source code
go

create view sys.dm_audit_class_type_map as
-- missing source code
go

create view sys.dm_broker_activated_tasks as
-- missing source code
go

create view sys.dm_broker_connections as
-- missing source code
go

create view sys.dm_broker_forwarded_messages as
-- missing source code
go

create view sys.dm_broker_queue_monitors as
-- missing source code
go

create view sys.dm_cache_hit_stats as
-- missing source code
go

create view sys.dm_cache_size as
-- missing source code
go

create view sys.dm_cache_stats as
-- missing source code
go

create view sys.dm_cdc_errors as
-- missing source code
go

create view sys.dm_cdc_log_scan_sessions as
-- missing source code
go

create view sys.dm_change_feed_errors as
-- missing source code
go

create view sys.dm_change_feed_log_scan_sessions as
-- missing source code
go

create view sys.dm_clr_appdomains as
-- missing source code
go

create view sys.dm_clr_loaded_assemblies as
-- missing source code
go

create view sys.dm_clr_properties as
-- missing source code
go

create view sys.dm_clr_tasks as
-- missing source code
go

create view sys.dm_cluster_endpoints as
-- missing source code
go

create view sys.dm_column_encryption_enclave as
-- missing source code
go

create view sys.dm_column_encryption_enclave_operation_stats as
-- missing source code
go

create view sys.dm_column_encryption_enclave_properties as
-- missing source code
go

create view sys.dm_column_store_object_pool as
-- missing source code
go

create view sys.dm_cryptographic_provider_properties as
-- missing source code
go

create view sys.dm_database_backups as
-- missing source code
go

create view sys.dm_database_encryption_keys as
-- missing source code
go

create view sys.dm_database_external_policy_actions as
-- missing source code
go

create view sys.dm_database_external_policy_principal_assigned_actions as
-- missing source code
go

create view sys.dm_database_external_policy_principals as
-- missing source code
go

create view sys.dm_database_external_policy_role_actions as
-- missing source code
go

create view sys.dm_database_external_policy_role_members as
-- missing source code
go

create view sys.dm_database_external_policy_roles as
-- missing source code
go

create view sys.dm_db_column_store_row_group_operational_stats as
-- missing source code
go

create view sys.dm_db_column_store_row_group_physical_stats as
-- missing source code
go

create view sys.dm_db_data_pool_nodes as
-- missing source code
go

create view sys.dm_db_data_pools as
-- missing source code
go

create view sys.dm_db_external_language_stats as
-- missing source code
go

create view sys.dm_db_external_script_execution_stats as
-- missing source code
go

create view sys.dm_db_file_space_usage as
-- missing source code
go

create view sys.dm_db_fts_index_physical_stats as
-- missing source code
go

create view sys.dm_db_index_usage_stats as
-- missing source code
go

create view sys.dm_db_log_space_usage as
-- missing source code
go

create view sys.dm_db_mirroring_auto_page_repair as
-- missing source code
go

create view sys.dm_db_mirroring_connections as
-- missing source code
go

create view sys.dm_db_mirroring_past_actions as
-- missing source code
go

create view sys.dm_db_missing_index_details as
-- missing source code
go

create view sys.dm_db_missing_index_group_stats as
-- missing source code
go

create view sys.dm_db_missing_index_group_stats_query as
-- missing source code
go

create view sys.dm_db_missing_index_groups as
-- missing source code
go

create view sys.dm_db_partition_stats as
-- missing source code
go

create view sys.dm_db_persisted_sku_features as
-- missing source code
go

create view sys.dm_db_rda_migration_status as
-- missing source code
go

create view sys.dm_db_rda_schema_update_status as
-- missing source code
go

create view sys.dm_db_script_level as
-- missing source code
go

create view sys.dm_db_session_space_usage as
-- missing source code
go

create view sys.dm_db_storage_pool_nodes as
-- missing source code
go

create view sys.dm_db_storage_pools as
-- missing source code
go

create view sys.dm_db_task_space_usage as
-- missing source code
go

create view sys.dm_db_tuning_recommendations as
-- missing source code
go

create view sys.dm_db_uncontained_entities as
-- missing source code
go

create view sys.dm_db_xtp_checkpoint_files as
-- missing source code
go

create view sys.dm_db_xtp_checkpoint_internals as
-- missing source code
go

create view sys.dm_db_xtp_checkpoint_stats as
-- missing source code
go

create view sys.dm_db_xtp_gc_cycle_stats as
-- missing source code
go

create view sys.dm_db_xtp_hash_index_stats as
-- missing source code
go

create view sys.dm_db_xtp_index_stats as
-- missing source code
go

create view sys.dm_db_xtp_memory_consumers as
-- missing source code
go

create view sys.dm_db_xtp_nonclustered_index_stats as
-- missing source code
go

create view sys.dm_db_xtp_object_stats as
-- missing source code
go

create view sys.dm_db_xtp_table_memory_stats as
-- missing source code
go

create view sys.dm_db_xtp_transactions as
-- missing source code
go

create view sys.dm_dist_requests as
-- missing source code
go

create view sys.dm_distributed_exchange_stats as
-- missing source code
go

create view sys.dm_dw_databases as
-- missing source code
go

create view sys.dm_dw_locks as
-- missing source code
go

create view sys.dm_dw_pit_databases as
-- missing source code
go

create view sys.dm_dw_quality_clustering as
-- missing source code
go

create view sys.dm_dw_quality_delta as
-- missing source code
go

create view sys.dm_dw_quality_index as
-- missing source code
go

create view sys.dm_dw_quality_row_group as
-- missing source code
go

create view sys.dm_dw_resource_manager_abort_cache as
-- missing source code
go

create view sys.dm_dw_resource_manager_active_tran as
-- missing source code
go

create view sys.dm_dw_tran_manager_abort_cache as
-- missing source code
go

create view sys.dm_dw_tran_manager_active_cache as
-- missing source code
go

create view sys.dm_dw_tran_manager_commit_cache as
-- missing source code
go

create view sys.dm_exec_background_job_queue as
-- missing source code
go

create view sys.dm_exec_background_job_queue_stats as
-- missing source code
go

create view sys.dm_exec_cached_plans as
-- missing source code
go

create view sys.dm_exec_compute_node_errors as
-- missing source code
go

create view sys.dm_exec_compute_node_status as
-- missing source code
go

create view sys.dm_exec_compute_nodes as
-- missing source code
go

create view sys.dm_exec_compute_pools as
-- missing source code
go

create view sys.dm_exec_connections as
-- missing source code
go

create view sys.dm_exec_distributed_request_steps as
-- missing source code
go

create view sys.dm_exec_distributed_requests as
-- missing source code
go

create view sys.dm_exec_distributed_sql_requests as
-- missing source code
go

create view sys.dm_exec_dms_services as
-- missing source code
go

create view sys.dm_exec_dms_workers as
-- missing source code
go

create view sys.dm_exec_external_operations as
-- missing source code
go

create view sys.dm_exec_external_work as
-- missing source code
go

create view sys.dm_exec_function_stats as
-- missing source code
go

create view sys.dm_exec_procedure_stats as
-- missing source code
go

create view sys.dm_exec_query_memory_grants as
-- missing source code
go

create view sys.dm_exec_query_optimizer_info as
-- missing source code
go

create view sys.dm_exec_query_optimizer_memory_gateways as
-- missing source code
go

create view sys.dm_exec_query_parallel_workers as
-- missing source code
go

create view sys.dm_exec_query_profiles as
-- missing source code
go

create view sys.dm_exec_query_resource_semaphores as
-- missing source code
go

create view sys.dm_exec_query_stats as
-- missing source code
go

create view sys.dm_exec_query_transformation_stats as
-- missing source code
go

create view sys.dm_exec_requests as
-- missing source code
go

create view sys.dm_exec_requests_history as
-- missing source code
go

create view sys.dm_exec_session_wait_stats as
-- missing source code
go

create view sys.dm_exec_sessions as
-- missing source code
go

create view sys.dm_exec_trigger_stats as
-- missing source code
go

create view sys.dm_exec_valid_use_hints as
-- missing source code
go

create view sys.dm_external_authentication as
-- missing source code
go

create view sys.dm_external_data_processed as
-- missing source code
go

create view sys.dm_external_policy_cache as
-- missing source code
go

create view sys.dm_external_provider_certificate_info as
-- missing source code
go

create view sys.dm_external_script_execution_stats as
-- missing source code
go

create view sys.dm_external_script_requests as
-- missing source code
go

create view sys.dm_external_script_resource_usage_stats as
-- missing source code
go

create view sys.dm_filestream_file_io_handles as
-- missing source code
go

create view sys.dm_filestream_file_io_requests as
-- missing source code
go

create view sys.dm_filestream_non_transacted_handles as
-- missing source code
go

create view sys.dm_fts_active_catalogs as
-- missing source code
go

create view sys.dm_fts_fdhosts as
-- missing source code
go

create view sys.dm_fts_index_population as
-- missing source code
go

create view sys.dm_fts_memory_buffers as
-- missing source code
go

create view sys.dm_fts_memory_pools as
-- missing source code
go

create view sys.dm_fts_outstanding_batches as
-- missing source code
go

create view sys.dm_fts_population_ranges as
-- missing source code
go

create view sys.dm_fts_semantic_similarity_population as
-- missing source code
go

create view sys.dm_hadr_ag_threads as
-- missing source code
go

create view sys.dm_hadr_auto_page_repair as
-- missing source code
go

create view sys.dm_hadr_automatic_seeding as
-- missing source code
go

create view sys.dm_hadr_availability_group_states as
-- missing source code
go

create view sys.dm_hadr_availability_replica_cluster_nodes as
-- missing source code
go

create view sys.dm_hadr_availability_replica_cluster_states as
-- missing source code
go

create view sys.dm_hadr_availability_replica_states as
-- missing source code
go

create view sys.dm_hadr_cached_database_replica_states as
-- missing source code
go

create view sys.dm_hadr_cached_replica_states as
-- missing source code
go

create view sys.dm_hadr_cluster as
-- missing source code
go

create view sys.dm_hadr_cluster_members as
-- missing source code
go

create view sys.dm_hadr_cluster_networks as
-- missing source code
go

create view sys.dm_hadr_database_replica_cluster_states as
-- missing source code
go

create view sys.dm_hadr_database_replica_states as
-- missing source code
go

create view sys.dm_hadr_db_threads as
-- missing source code
go

create view sys.dm_hadr_instance_node_map as
-- missing source code
go

create view sys.dm_hadr_name_id_map as
-- missing source code
go

create view sys.dm_hadr_physical_seeding_stats as
-- missing source code
go

create view sys.dm_hpc_device_stats as
-- missing source code
go

create view sys.dm_hpc_thread_proxy_stats as
-- missing source code
go

create view sys.dm_io_backup_tapes as
-- missing source code
go

create view sys.dm_io_cluster_shared_drives as
-- missing source code
go

create view sys.dm_io_cluster_valid_path_names as
-- missing source code
go

create view sys.dm_io_pending_io_requests as
-- missing source code
go

create view sys.dm_logpool_hashentries as
-- missing source code
go

create view sys.dm_logpool_stats as
-- missing source code
go

create view sys.dm_os_buffer_descriptors as
-- missing source code
go

create view sys.dm_os_buffer_pool_extension_configuration as
-- missing source code
go

create view sys.dm_os_child_instances as
-- missing source code
go

create view sys.dm_os_cluster_nodes as
-- missing source code
go

create view sys.dm_os_cluster_properties as
-- missing source code
go

create view sys.dm_os_dispatcher_pools as
-- missing source code
go

create view sys.dm_os_dispatchers as
-- missing source code
go

create view sys.dm_os_enumerate_fixed_drives as
-- missing source code
go

create view sys.dm_os_host_info as
-- missing source code
go

create view sys.dm_os_hosts as
-- missing source code
go

create view sys.dm_os_job_object as
-- missing source code
go

create view sys.dm_os_latch_stats as
-- missing source code
go

create view sys.dm_os_loaded_modules as
-- missing source code
go

create view sys.dm_os_memory_allocations as
-- missing source code
go

create view sys.dm_os_memory_broker_clerks as
-- missing source code
go

create view sys.dm_os_memory_brokers as
-- missing source code
go

create view sys.dm_os_memory_cache_clock_hands as
-- missing source code
go

create view sys.dm_os_memory_cache_counters as
-- missing source code
go

create view sys.dm_os_memory_cache_entries as
-- missing source code
go

create view sys.dm_os_memory_cache_hash_tables as
-- missing source code
go

create view sys.dm_os_memory_clerks as
-- missing source code
go

create view sys.dm_os_memory_node_access_stats as
-- missing source code
go

create view sys.dm_os_memory_nodes as
-- missing source code
go

create view sys.dm_os_memory_objects as
-- missing source code
go

create view sys.dm_os_memory_pools as
-- missing source code
go

create view sys.dm_os_nodes as
-- missing source code
go

create view sys.dm_os_out_of_memory_events as
-- missing source code
go

create view sys.dm_os_performance_counters as
-- missing source code
go

create view sys.dm_os_process_memory as
-- missing source code
go

create view sys.dm_os_ring_buffers as
-- missing source code
go

create view sys.dm_os_schedulers as
-- missing source code
go

create view sys.dm_os_server_diagnostics_log_configurations as
-- missing source code
go

create view sys.dm_os_spinlock_stats as
-- missing source code
go

create view sys.dm_os_stacks as
-- missing source code
go

create view sys.dm_os_sublatches as
-- missing source code
go

create view sys.dm_os_sys_info as
-- missing source code
go

create view sys.dm_os_sys_memory as
-- missing source code
go

create view sys.dm_os_tasks as
-- missing source code
go

create view sys.dm_os_threads as
-- missing source code
go

create view sys.dm_os_virtual_address_dump as
-- missing source code
go

create view sys.dm_os_wait_stats as
-- missing source code
go

create view sys.dm_os_waiting_tasks as
-- missing source code
go

create view sys.dm_os_windows_info as
-- missing source code
go

create view sys.dm_os_worker_local_storage as
-- missing source code
go

create view sys.dm_os_workers as
-- missing source code
go

create view sys.dm_pal_cpu_stats as
-- missing source code
go

create view sys.dm_pal_disk_stats as
-- missing source code
go

create view sys.dm_pal_net_stats as
-- missing source code
go

create view sys.dm_pal_processes as
-- missing source code
go

create view sys.dm_pal_spinlock_stats as
-- missing source code
go

create view sys.dm_pal_vm_stats as
-- missing source code
go

create view sys.dm_pal_wait_stats as
-- missing source code
go

create view sys.dm_qn_subscriptions as
-- missing source code
go

create view sys.dm_repl_articles as
-- missing source code
go

create view sys.dm_repl_schemas as
-- missing source code
go

create view sys.dm_repl_tranhash as
-- missing source code
go

create view sys.dm_repl_traninfo as
-- missing source code
go

create view sys.dm_request_phases as
-- missing source code
go

create view sys.dm_request_phases_exec_task_stats as
-- missing source code
go

create view sys.dm_request_phases_task_group_stats as
-- missing source code
go

create view sys.dm_resource_governor_configuration as
-- missing source code
go

create view sys.dm_resource_governor_external_resource_pool_affinity as
-- missing source code
go

create view sys.dm_resource_governor_external_resource_pools as
-- missing source code
go

create view sys.dm_resource_governor_resource_pool_affinity as
-- missing source code
go

create view sys.dm_resource_governor_resource_pool_volumes as
-- missing source code
go

create view sys.dm_resource_governor_resource_pools as
-- missing source code
go

create view sys.dm_resource_governor_workload_groups as
-- missing source code
go

create view sys.dm_server_accelerator_status as
-- missing source code
go

create view sys.dm_server_audit_status as
-- missing source code
go

create view sys.dm_server_external_policy_actions as
-- missing source code
go

create view sys.dm_server_external_policy_principal_assigned_actions as
-- missing source code
go

create view sys.dm_server_external_policy_principals as
-- missing source code
go

create view sys.dm_server_external_policy_role_actions as
-- missing source code
go

create view sys.dm_server_external_policy_role_members as
-- missing source code
go

create view sys.dm_server_external_policy_roles as
-- missing source code
go

create view sys.dm_server_memory_dumps as
-- missing source code
go

create view sys.dm_server_registry as
-- missing source code
go

create view sys.dm_server_services as
-- missing source code
go

create view sys.dm_server_suspend_status as
-- missing source code
go

create view sys.dm_tcp_listener_states as
-- missing source code
go

create view sys.dm_toad_tuning_zones as
-- missing source code
go

create view sys.dm_toad_work_item_handlers as
-- missing source code
go

create view sys.dm_toad_work_items as
-- missing source code
go

create view sys.dm_tran_aborted_transactions as
-- missing source code
go

create view sys.dm_tran_active_snapshot_database_transactions as
-- missing source code
go

create view sys.dm_tran_active_transactions as
-- missing source code
go

create view sys.dm_tran_commit_table as
-- missing source code
go

create view sys.dm_tran_current_snapshot as
-- missing source code
go

create view sys.dm_tran_current_transaction as
-- missing source code
go

create view sys.dm_tran_database_transactions as
-- missing source code
go

create view sys.dm_tran_distributed_transaction_stats as
-- missing source code
go

create view sys.dm_tran_global_recovery_transactions as
-- missing source code
go

create view sys.dm_tran_global_transactions as
-- missing source code
go

create view sys.dm_tran_global_transactions_enlistments as
-- missing source code
go

create view sys.dm_tran_global_transactions_log as
-- missing source code
go

create view sys.dm_tran_locks as
-- missing source code
go

create view sys.dm_tran_orphaned_distributed_transactions as
-- missing source code
go

create view sys.dm_tran_persistent_version_store as
-- missing source code
go

create view sys.dm_tran_persistent_version_store_stats as
-- missing source code
go

create view sys.dm_tran_session_transactions as
-- missing source code
go

create view sys.dm_tran_top_version_generators as
-- missing source code
go

create view sys.dm_tran_transactions_snapshot as
-- missing source code
go

create view sys.dm_tran_version_store as
-- missing source code
go

create view sys.dm_tran_version_store_space_usage as
-- missing source code
go

create view sys.dm_xe_map_values as
-- missing source code
go

create view sys.dm_xe_object_columns as
-- missing source code
go

create view sys.dm_xe_objects as
-- missing source code
go

create view sys.dm_xe_packages as
-- missing source code
go

create view sys.dm_xe_session_event_actions as
-- missing source code
go

create view sys.dm_xe_session_events as
-- missing source code
go

create view sys.dm_xe_session_object_columns as
-- missing source code
go

create view sys.dm_xe_session_targets as
-- missing source code
go

create view sys.dm_xe_sessions as
-- missing source code
go

create view sys.dm_xtp_gc_queue_stats as
-- missing source code
go

create view sys.dm_xtp_gc_stats as
-- missing source code
go

create view sys.dm_xtp_system_memory_consumers as
-- missing source code
go

create view sys.dm_xtp_threads as
-- missing source code
go

create view sys.dm_xtp_transaction_recent_rows as
-- missing source code
go

create view sys.dm_xtp_transaction_stats as
-- missing source code
go

create view sys.edge_constraint_clauses as
-- missing source code
go

create view sys.edge_constraints as
-- missing source code
go

create view sys.endpoint_webmethods as
-- missing source code
go

create view sys.endpoints as
-- missing source code
go

create view sys.event_notification_event_types as
-- missing source code
go

create view sys.event_notifications as
-- missing source code
go

create view sys.events as
-- missing source code
go

create view sys.extended_procedures as
-- missing source code
go

create view sys.extended_properties as
-- missing source code
go

create view sys.external_data_sources as
-- missing source code
go

create view sys.external_file_formats as
-- missing source code
go

create view sys.external_job_streams as
-- missing source code
go

create view sys.external_language_files as
-- missing source code
go

create view sys.external_languages as
-- missing source code
go

create view sys.external_libraries as
-- missing source code
go

create view sys.external_libraries_installed as
-- missing source code
go

create view sys.external_library_files as
-- missing source code
go

create view sys.external_library_setup_errors as
-- missing source code
go

create view sys.external_stream_columns as
-- missing source code
go

create view sys.external_streaming_jobs as
-- missing source code
go

create view sys.external_streams as
-- missing source code
go

create view sys.external_table_columns as
-- missing source code
go

create view sys.external_table_partitioning_columns as
-- missing source code
go

create view sys.external_tables as
-- missing source code
go

create view sys.filegroups as
-- missing source code
go

create view sys.filetable_system_defined_objects as
-- missing source code
go

create view sys.filetables as
-- missing source code
go

create view sys.foreign_key_columns as
-- missing source code
go

create view sys.foreign_keys as
-- missing source code
go

create view sys.fulltext_catalogs as
-- missing source code
go

create view sys.fulltext_document_types as
-- missing source code
go

create view sys.fulltext_index_catalog_usages as
-- missing source code
go

create view sys.fulltext_index_columns as
-- missing source code
go

create view sys.fulltext_index_fragments as
-- missing source code
go

create view sys.fulltext_indexes as
-- missing source code
go

create view sys.fulltext_languages as
-- missing source code
go

create view sys.fulltext_semantic_language_statistics_database as
-- missing source code
go

create view sys.fulltext_semantic_languages as
-- missing source code
go

create view sys.fulltext_stoplists as
-- missing source code
go

create view sys.fulltext_stopwords as
-- missing source code
go

create view sys.fulltext_system_stopwords as
-- missing source code
go

create view sys.function_order_columns as
-- missing source code
go

create view sys.hash_indexes as
-- missing source code
go

create view sys.http_endpoints as
-- missing source code
go

create view sys.identity_columns as
-- missing source code
go

create view sys.index_columns as
-- missing source code
go

create view sys.index_resumable_operations as
-- missing source code
go

create view sys.indexes as
-- missing source code
go

create view sys.internal_partitions as
-- missing source code
go

create view sys.internal_tables as
-- missing source code
go

create view sys.key_constraints as
-- missing source code
go

create view sys.key_encryptions as
-- missing source code
go

create view sys.ledger_column_history as
-- missing source code
go

create view sys.ledger_table_history as
-- missing source code
go

create view sys.linked_logins as
-- missing source code
go

create view sys.login_token as
-- missing source code
go

create view sys.masked_columns as
-- missing source code
go

create view sys.master_files as
-- missing source code
go

create view sys.master_key_passwords as
-- missing source code
go

create view sys.memory_optimized_tables_internal_attributes as
-- missing source code
go

create view sys.message_type_xml_schema_collection_usages as
-- missing source code
go

create view sys.messages as
-- missing source code
go

create view sys.module_assembly_usages as
-- missing source code
go

create view sys.numbered_procedure_parameters as
-- missing source code
go

create view sys.numbered_procedures as
-- missing source code
go

create view sys.objects as
-- missing source code
go

create view sys.openkeys as
-- missing source code
go

create view sys.parameter_type_usages as
-- missing source code
go

create view sys.parameter_xml_schema_collection_usages as
-- missing source code
go

create view sys.parameters as
-- missing source code
go

create view sys.partition_functions as
-- missing source code
go

create view sys.partition_parameters as
-- missing source code
go

create view sys.partition_range_values as
-- missing source code
go

create view sys.partition_schemes as
-- missing source code
go

create view sys.partitions as
-- missing source code
go

create view sys.periods as
-- missing source code
go

create view sys.plan_guides as
-- missing source code
go

create view sys.procedures as
-- missing source code
go

create view sys.query_context_settings as
-- missing source code
go

create view sys.query_store_plan as
-- missing source code
go

create view sys.query_store_plan_feedback as
-- missing source code
go

create view sys.query_store_plan_forcing_locations as
-- missing source code
go

create view sys.query_store_query as
-- missing source code
go

create view sys.query_store_query_hints as
-- missing source code
go

create view sys.query_store_query_text as
-- missing source code
go

create view sys.query_store_query_variant as
-- missing source code
go

create view sys.query_store_replicas as
-- missing source code
go

create view sys.query_store_runtime_stats as
-- missing source code
go

create view sys.query_store_runtime_stats_interval as
-- missing source code
go

create view sys.query_store_wait_stats as
-- missing source code
go

create view sys.registered_search_properties as
-- missing source code
go

create view sys.registered_search_property_lists as
-- missing source code
go

create view sys.remote_data_archive_databases as
-- missing source code
go

create view sys.remote_data_archive_tables as
-- missing source code
go

create view sys.remote_logins as
-- missing source code
go

create view sys.remote_service_bindings as
-- missing source code
go

create view sys.resource_governor_configuration as
-- missing source code
go

create view sys.resource_governor_external_resource_pool_affinity as
-- missing source code
go

create view sys.resource_governor_external_resource_pools as
-- missing source code
go

create view sys.resource_governor_resource_pool_affinity as
-- missing source code
go

create view sys.resource_governor_resource_pools as
-- missing source code
go

create view sys.resource_governor_workload_groups as
-- missing source code
go

create view sys.routes as
-- missing source code
go

create view sys.schemas as
-- missing source code
go

create view sys.securable_classes as
-- missing source code
go

create view sys.security_policies as
-- missing source code
go

create view sys.security_predicates as
-- missing source code
go

create view sys.selective_xml_index_namespaces as
-- missing source code
go

create view sys.selective_xml_index_paths as
-- missing source code
go

create view sys.sensitivity_classifications as
-- missing source code
go

create view sys.sequences as
-- missing source code
go

create view sys.server_assembly_modules as
-- missing source code
go

create view sys.server_audit_specification_details as
-- missing source code
go

create view sys.server_audit_specifications as
-- missing source code
go

create view sys.server_audits as
-- missing source code
go

create view sys.server_event_notifications as
-- missing source code
go

create view sys.server_event_session_actions as
-- missing source code
go

create view sys.server_event_session_events as
-- missing source code
go

create view sys.server_event_session_fields as
-- missing source code
go

create view sys.server_event_session_targets as
-- missing source code
go

create view sys.server_event_sessions as
-- missing source code
go

create view sys.server_events as
-- missing source code
go

create view sys.server_file_audits as
-- missing source code
go

create view sys.server_memory_optimized_hybrid_buffer_pool_configuration as
-- missing source code
go

create view sys.server_permissions as
-- missing source code
go

create view sys.server_principal_credentials as
-- missing source code
go

create view sys.server_principals as
-- missing source code
go

create view sys.server_role_members as
-- missing source code
go

create view sys.server_sql_modules as
-- missing source code
go

create view sys.server_trigger_events as
-- missing source code
go

create view sys.server_triggers as
-- missing source code
go

create view sys.servers as
-- missing source code
go

create view sys.service_broker_endpoints as
-- missing source code
go

create view sys.service_contract_message_usages as
-- missing source code
go

create view sys.service_contract_usages as
-- missing source code
go

create view sys.service_contracts as
-- missing source code
go

create view sys.service_message_types as
-- missing source code
go

create view sys.service_queue_usages as
-- missing source code
go

create view sys.service_queues as
-- missing source code
go

create view sys.services as
-- missing source code
go

create view sys.soap_endpoints as
-- missing source code
go

create view sys.spatial_index_tessellations as
-- missing source code
go

create view sys.spatial_indexes as
-- missing source code
go

create view sys.spatial_reference_systems as
-- missing source code
go

create view sys.sql_dependencies as
-- missing source code
go

create view sys.sql_expression_dependencies as
-- missing source code
go

create view sys.sql_logins as
-- missing source code
go

create view sys.sql_modules as
-- missing source code
go

create view sys.stats as
-- missing source code
go

create view sys.stats_columns as
-- missing source code
go

create view sys.symmetric_keys as
-- missing source code
go

create view sys.synonyms as
-- missing source code
go

create view sys.sysaltfiles as
-- missing source code
go

create view sys.syscacheobjects as
-- missing source code
go

create view sys.syscharsets as
-- missing source code
go

create view sys.syscolumns as
-- missing source code
go

create view sys.syscomments as
-- missing source code
go

create view sys.sysconfigures as
-- missing source code
go

create view sys.sysconstraints as
-- missing source code
go

create view sys.syscscontainers as
-- missing source code
go

create view sys.syscurconfigs as
-- missing source code
go

create view sys.syscursorcolumns as
-- missing source code
go

create view sys.syscursorrefs as
-- missing source code
go

create view sys.syscursors as
-- missing source code
go

create view sys.syscursortables as
-- missing source code
go

create view sys.sysdatabases as
-- missing source code
go

create view sys.sysdepends as
-- missing source code
go

create view sys.sysdevices as
-- missing source code
go

create view sys.sysfilegroups as
-- missing source code
go

create view sys.sysfiles as
-- missing source code
go

create view sys.sysforeignkeys as
-- missing source code
go

create view sys.sysfulltextcatalogs as
-- missing source code
go

create view sys.sysindexes as
-- missing source code
go

create view sys.sysindexkeys as
-- missing source code
go

create view sys.syslanguages as
-- missing source code
go

create view sys.syslockinfo as
-- missing source code
go

create view sys.syslogins as
-- missing source code
go

create view sys.sysmembers as
-- missing source code
go

create view sys.sysmessages as
-- missing source code
go

create view sys.sysobjects as
-- missing source code
go

create view sys.sysoledbusers as
-- missing source code
go

create view sys.sysopentapes as
-- missing source code
go

create view sys.sysperfinfo as
-- missing source code
go

create view sys.syspermissions as
-- missing source code
go

create view sys.sysprocesses as
-- missing source code
go

create view sys.sysprotects as
-- missing source code
go

create view sys.sysreferences as
-- missing source code
go

create view sys.sysremotelogins as
-- missing source code
go

create view sys.sysservers as
-- missing source code
go

create view sys.system_columns as
-- missing source code
go

create view sys.system_components_surface_area_configuration as
-- missing source code
go

create view sys.system_internals_allocation_units as
-- missing source code
go

create view sys.system_internals_partition_columns as
-- missing source code
go

create view sys.system_internals_partitions as
-- missing source code
go

create view sys.system_objects as
-- missing source code
go

create view sys.system_parameters as
-- missing source code
go

create view sys.system_sql_modules as
-- missing source code
go

create view sys.system_views as
-- missing source code
go

create view sys.systypes as
-- missing source code
go

create view sys.sysusers as
-- missing source code
go

create view sys.table_types as
-- missing source code
go

create view sys.tables as
-- missing source code
go

create view sys.tcp_endpoints as
-- missing source code
go

create view sys.time_zone_info as
-- missing source code
go

create view sys.trace_categories as
-- missing source code
go

create view sys.trace_columns as
-- missing source code
go

create view sys.trace_event_bindings as
-- missing source code
go

create view sys.trace_events as
-- missing source code
go

create view sys.trace_subclass_values as
-- missing source code
go

create view sys.traces as
-- missing source code
go

create view sys.transmission_queue as
-- missing source code
go

create view sys.trigger_event_types as
-- missing source code
go

create view sys.trigger_events as
-- missing source code
go

create view sys.triggers as
-- missing source code
go

create view sys.trusted_assemblies as
-- missing source code
go

create view sys.type_assembly_usages as
-- missing source code
go

create view sys.types as
-- missing source code
go

create view sys.user_token as
-- missing source code
go

create view sys.via_endpoints as
-- missing source code
go

create view sys.views as
-- missing source code
go

create view sys.xml_indexes as
-- missing source code
go

create view sys.xml_schema_attributes as
-- missing source code
go

create view sys.xml_schema_collections as
-- missing source code
go

create view sys.xml_schema_component_placements as
-- missing source code
go

create view sys.xml_schema_components as
-- missing source code
go

create view sys.xml_schema_elements as
-- missing source code
go

create view sys.xml_schema_facets as
-- missing source code
go

create view sys.xml_schema_model_groups as
-- missing source code
go

create view sys.xml_schema_namespaces as
-- missing source code
go

create view sys.xml_schema_types as
-- missing source code
go

create view sys.xml_schema_wildcard_namespaces as
-- missing source code
go

create view sys.xml_schema_wildcards as
-- missing source code
go

create function sys.dm_cryptographic_provider_algorithms(@ProviderId int) returns table as
-- missing source code
go

create function sys.dm_cryptographic_provider_keys(@ProviderId int) returns table as
-- missing source code
go

create function sys.dm_cryptographic_provider_sessions(@all int) returns table as
-- missing source code
go

create function sys.dm_db_database_page_allocations(@DatabaseId smallint, @TableId int, @IndexId int,
                                                    @PartitionId bigint, @Mode nvarchar(64)) returns table as
-- missing source code
go

create function sys.dm_db_incremental_stats_properties(@object_id int, @stats_id int) returns table as
-- missing source code
go

create function sys.dm_db_index_operational_stats(@DatabaseId smallint, @TableId int, @IndexId int,
                                                  @PartitionNumber int) returns table as
-- missing source code
go

create function sys.dm_db_index_physical_stats(@DatabaseId smallint, @ObjectId int, @IndexId int, @PartitionNumber int,
                                               @Mode nvarchar(20)) returns table as
-- missing source code
go

create function sys.dm_db_log_info(@DatabaseId int) returns table as
-- missing source code
go

create function sys.dm_db_log_stats(@DatabaseId int) returns table as
-- missing source code
go

create function sys.dm_db_missing_index_columns(@handle int) returns table as
-- missing source code
go

create function sys.dm_db_objects_disabled_on_compatibility_level_change(@compatibility_level int) returns table as
-- missing source code
go

create function sys.dm_db_page_info(@DatabaseId smallint, @FileId int, @PageId int, @Mode nvarchar(64)) returns table as
-- missing source code
go

create function sys.dm_db_stats_histogram(@object_id int, @stats_id int) returns table as
-- missing source code
go

create function sys.dm_db_stats_properties(@object_id int, @stats_id int) returns table as
-- missing source code
go

create function sys.dm_db_stats_properties_internal(@object_id int, @stats_id int) returns table as
-- missing source code
go

create function sys.dm_db_xtp_hash_index_approx_stats(@maxComputeTime int, @maxRowsToScanPerBucket int) returns table as
-- missing source code
go

create function sys.dm_exec_cached_plan_dependent_objects(@planhandle varbinary(64)) returns table as
-- missing source code
go

create function sys.dm_exec_cursors(@spid int) returns table as
-- missing source code
go

create function sys.dm_exec_describe_first_result_set(@tsql nvarchar(max), @params nvarchar(max),
                                                      @browse_information_mode tinyint) returns table as
-- missing source code
go

create function sys.dm_exec_describe_first_result_set_for_object(@object_id int, @browse_information_mode tinyint) returns table as
-- missing source code
go

create function sys.dm_exec_input_buffer(@session_id smallint, @request_id int) returns table as
-- missing source code
go

create function sys.dm_exec_plan_attributes(@handle varbinary(64)) returns table as
-- missing source code
go

create function sys.dm_exec_query_plan(@handle varbinary(64)) returns table as
-- missing source code
go

create function sys.dm_exec_query_plan_stats(@handle varbinary(64)) returns table as
-- missing source code
go

create function sys.dm_exec_query_statistics_xml(@session_id smallint) returns table as
-- missing source code
go

create function sys.dm_exec_sql_text(@handle varbinary(64)) returns table as
-- missing source code
go

create function sys.dm_exec_text_query_plan(@handle varbinary(64), @stmt_start_offset int, @stmt_end_offset int) returns table as
-- missing source code
go

create function sys.dm_exec_xml_handles(@spid int) returns table as
-- missing source code
go

create function sys.dm_fts_index_keywords(@dbid int, @objid int) returns table as
-- missing source code
go

create function sys.dm_fts_index_keywords_by_document(@dbid int, @objid int) returns table as
-- missing source code
go

create function sys.dm_fts_index_keywords_by_property(@dbid int, @objid int) returns table as
-- missing source code
go

create function sys.dm_fts_index_keywords_position_by_document(@dbid int, @objid int) returns table as
-- missing source code
go

create function sys.dm_fts_parser(@querystring nvarchar(4000), @lcid int, @stoplistid int,
                                  @accentsensitive bit) returns table as
-- missing source code
go

create function sys.dm_io_virtual_file_stats(@DatabaseId int, @FileId int) returns table as
-- missing source code
go

create function sys.dm_logconsumer_cachebufferrefs(@DatabaseId int, @ConsumerId bigint) returns table as
-- missing source code
go

create function sys.dm_logconsumer_privatecachebuffers(@DatabaseId int, @ConsumerId bigint) returns table as
-- missing source code
go

create function sys.dm_logpool_consumers(@DatabaseId int) returns table as
-- missing source code
go

create function sys.dm_logpool_sharedcachebuffers(@DatabaseId int) returns table as
-- missing source code
go

create function sys.dm_logpoolmgr_freepools(@DatabaseId int) returns table as
-- missing source code
go

create function sys.dm_logpoolmgr_respoolsize(@DatabaseId int) returns table as
-- missing source code
go

create function sys.dm_logpoolmgr_stats(@DatabaseId int) returns table as
-- missing source code
go

create function sys.dm_os_enumerate_filesystem(@initial_directory nvarchar(255), @search_pattern nvarchar(255)) returns table as
-- missing source code
go

create function sys.dm_os_file_exists(@file_or_directory nvarchar(255)) returns table as
-- missing source code
go

create function sys.dm_os_volume_stats(@DatabaseId int, @FileId int) returns table as
-- missing source code
go

create function sys.dm_sql_referenced_entities(@name nvarchar(517), @referencing_class nvarchar(60)) returns table as
-- missing source code
go

create function sys.dm_sql_referencing_entities(@name nvarchar(517), @referenced_class nvarchar(60)) returns table as
-- missing source code
go

create function sys.dm_xcs_enumerate_blobdirectory(@container_path nvarchar(4000), @datasource_name nvarchar(128),
                                                   @token nvarchar(4000), @object_id int,
                                                   @infer_partitions bit) returns table as
-- missing source code
go

create function sys.fn_EnumCurrentPrincipals() returns table as
-- missing source code
go

create function sys.fn_GetCurrentPrincipal(@db_name sysname) returns sysname as
-- missing source code
go

create function sys.fn_GetRowsetIdFromRowDump(@rowdump varbinary(max)) returns bigint as
-- missing source code
go

create function sys.fn_IsBitSetInBitmask(@bitmask varbinary(500), @colid int) returns int as
-- missing source code
go

create function sys.fn_MSdayasnumber(@day datetime) returns int as
-- missing source code
go

create function sys.fn_MSgeneration_downloadonly(@generation bigint, @tablenick int) returns bigint as
-- missing source code
go

create function sys.fn_MSget_dynamic_filter_login(@publication_number int, @partition_id int) returns sysname as
-- missing source code
go

create function sys.fn_MSorbitmaps(@bm1 varbinary(128), @bm2 varbinary(128)) returns varbinary(128) as
-- missing source code
go

create function sys.fn_MSrepl_getsrvidfromdistdb(@srvid smallint) returns int as
-- missing source code
go

create function sys.fn_MSrepl_map_resolver_clsid(@compatibility_level int, @article_resolver nvarchar(255),
                                                 @resolver_clsid nvarchar(60)) returns nvarchar(60) as
-- missing source code
go

create function sys.fn_MStestbit(@bitmap varbinary(128), @colidx smallint) returns bit as
-- missing source code
go

create function sys.fn_MSvector_downloadonly(@vector varbinary(2953), @tablenick int) returns varbinary(311) as
-- missing source code
go

create function sys.fn_MSxe_read_event_stream(@source nvarchar(260), @source_opt int) returns table as
-- missing source code
go

create function sys.fn_MapSchemaType(@schematype int, @schemasubtype int) returns sysname as
-- missing source code
go

create function sys.fn_PageResCracker(@page_resource binary(8)) returns table as
-- missing source code
go

create function sys.fn_PhysLocCracker(@physical_locator binary(8)) returns table as
-- missing source code
go

create function sys.fn_PhysLocFormatter(@physical_locator binary(8)) returns varchar(128) as
-- missing source code
go

create function sys.fn_RowDumpCracker(@rowdump varbinary(max)) returns table as
-- missing source code
go

create function sys.fn_builtin_permissions(@level nvarchar(60)) returns table as
-- missing source code
go

create function sys.fn_cColvEntries_80(@pubid uniqueidentifier, @artnick int) returns int as
-- missing source code
go

create function sys.fn_cdc_check_parameters(@capture_instance sysname, @from_lsn binary(10), @to_lsn binary(10),
                                            @row_filter_option nvarchar(30), @net_changes bit) returns bit as
-- missing source code
go

create function sys.fn_cdc_get_column_ordinal(@capture_instance sysname, @column_name sysname) returns int as
-- missing source code
go

create function sys.fn_cdc_get_max_lsn() returns binary(10) as
-- missing source code
go

create function sys.fn_cdc_get_min_lsn(@capture_instance sysname) returns binary(10) as
-- missing source code
go

create function sys.fn_cdc_has_column_changed(@capture_instance sysname, @column_name sysname,
                                              @update_mask varbinary(128)) returns bit as
-- missing source code
go

create function sys.fn_cdc_hexstrtobin(@hexstr nvarchar(40)) returns binary(10) as
-- missing source code
go

create function sys.fn_cdc_is_ddl_handling_enabled(@object_id int) returns bit as
-- missing source code
go

create function sys.fn_cdc_map_lsn_to_time(@lsn binary(10)) returns datetime as
-- missing source code
go

create function sys.fn_cdc_map_time_to_lsn(@relational_operator nvarchar(30), @tracking_time datetime) returns binary(10) as
-- missing source code
go

create function sys.fn_check_object_signatures(@class sysname, @thumbprint varbinary(20)) returns table as
-- missing source code
go

create function sys.fn_column_store_row_groups(@obj_id bigint) returns table as
-- missing source code
go

create function sys.fn_db_backup_file_snapshots(@database_name sysname) returns table as
-- missing source code
go

create function sys.fn_dblog(@start nvarchar(25), @end nvarchar(25)) returns table as
-- missing source code
go

create function sys.fn_dblog_xtp(@start nvarchar(25), @end nvarchar(25)) returns table as
-- missing source code
go

create function sys.fn_dbslog(@start nvarchar(25), @end nvarchar(25)) returns table as
-- missing source code
go

create function sys.fn_dump_dblog(@start nvarchar(25), @end nvarchar(25), @devtype nvarchar(260), @seqnum int,
                                  @fname1 nvarchar(260), @fname2 nvarchar(260), @fname3 nvarchar(260),
                                  @fname4 nvarchar(260), @fname5 nvarchar(260), @fname6 nvarchar(260),
                                  @fname7 nvarchar(260), @fname8 nvarchar(260), @fname9 nvarchar(260),
                                  @fname10 nvarchar(260), @fname11 nvarchar(260), @fname12 nvarchar(260),
                                  @fname13 nvarchar(260), @fname14 nvarchar(260), @fname15 nvarchar(260),
                                  @fname16 nvarchar(260), @fname17 nvarchar(260), @fname18 nvarchar(260),
                                  @fname19 nvarchar(260), @fname20 nvarchar(260), @fname21 nvarchar(260),
                                  @fname22 nvarchar(260), @fname23 nvarchar(260), @fname24 nvarchar(260),
                                  @fname25 nvarchar(260), @fname26 nvarchar(260), @fname27 nvarchar(260),
                                  @fname28 nvarchar(260), @fname29 nvarchar(260), @fname30 nvarchar(260),
                                  @fname31 nvarchar(260), @fname32 nvarchar(260), @fname33 nvarchar(260),
                                  @fname34 nvarchar(260), @fname35 nvarchar(260), @fname36 nvarchar(260),
                                  @fname37 nvarchar(260), @fname38 nvarchar(260), @fname39 nvarchar(260),
                                  @fname40 nvarchar(260), @fname41 nvarchar(260), @fname42 nvarchar(260),
                                  @fname43 nvarchar(260), @fname44 nvarchar(260), @fname45 nvarchar(260),
                                  @fname46 nvarchar(260), @fname47 nvarchar(260), @fname48 nvarchar(260),
                                  @fname49 nvarchar(260), @fname50 nvarchar(260), @fname51 nvarchar(260),
                                  @fname52 nvarchar(260), @fname53 nvarchar(260), @fname54 nvarchar(260),
                                  @fname55 nvarchar(260), @fname56 nvarchar(260), @fname57 nvarchar(260),
                                  @fname58 nvarchar(260), @fname59 nvarchar(260), @fname60 nvarchar(260),
                                  @fname61 nvarchar(260), @fname62 nvarchar(260), @fname63 nvarchar(260),
                                  @fname64 nvarchar(260)) returns table as
-- missing source code
go

create function sys.fn_dump_dblog_xtp(@start nvarchar(25), @end nvarchar(25), @devtype nvarchar(260), @seqnum int,
                                      @fname1 nvarchar(260), @fname2 nvarchar(260), @fname3 nvarchar(260),
                                      @fname4 nvarchar(260), @fname5 nvarchar(260), @fname6 nvarchar(260),
                                      @fname7 nvarchar(260), @fname8 nvarchar(260), @fname9 nvarchar(260),
                                      @fname10 nvarchar(260), @fname11 nvarchar(260), @fname12 nvarchar(260),
                                      @fname13 nvarchar(260), @fname14 nvarchar(260), @fname15 nvarchar(260),
                                      @fname16 nvarchar(260), @fname17 nvarchar(260), @fname18 nvarchar(260),
                                      @fname19 nvarchar(260), @fname20 nvarchar(260), @fname21 nvarchar(260),
                                      @fname22 nvarchar(260), @fname23 nvarchar(260), @fname24 nvarchar(260),
                                      @fname25 nvarchar(260), @fname26 nvarchar(260), @fname27 nvarchar(260),
                                      @fname28 nvarchar(260), @fname29 nvarchar(260), @fname30 nvarchar(260),
                                      @fname31 nvarchar(260), @fname32 nvarchar(260), @fname33 nvarchar(260),
                                      @fname34 nvarchar(260), @fname35 nvarchar(260), @fname36 nvarchar(260),
                                      @fname37 nvarchar(260), @fname38 nvarchar(260), @fname39 nvarchar(260),
                                      @fname40 nvarchar(260), @fname41 nvarchar(260), @fname42 nvarchar(260),
                                      @fname43 nvarchar(260), @fname44 nvarchar(260), @fname45 nvarchar(260),
                                      @fname46 nvarchar(260), @fname47 nvarchar(260), @fname48 nvarchar(260),
                                      @fname49 nvarchar(260), @fname50 nvarchar(260), @fname51 nvarchar(260),
                                      @fname52 nvarchar(260), @fname53 nvarchar(260), @fname54 nvarchar(260),
                                      @fname55 nvarchar(260), @fname56 nvarchar(260), @fname57 nvarchar(260),
                                      @fname58 nvarchar(260), @fname59 nvarchar(260), @fname60 nvarchar(260),
                                      @fname61 nvarchar(260), @fname62 nvarchar(260), @fname63 nvarchar(260),
                                      @fname64 nvarchar(260)) returns table as
-- missing source code
go

create function sys.fn_fIsColTracked(@artnick int) returns int as
-- missing source code
go

create function sys.fn_filelog(@fname nvarchar(260)) returns table as
-- missing source code
go

create function sys.fn_full_dblog(@start nvarchar(25), @end nvarchar(25), @dbid int, @logical_dbid nvarchar(260),
                                  @backup_account nvarchar(260), @backup_container nvarchar(260), @page_fid int,
                                  @page_pid int, @init_prev_page_lsn nvarchar(25), @xdes_id_high int,
                                  @xdes_id_low int) returns table as
-- missing source code
go

create function sys.fn_get_audit_file(@file_pattern nvarchar(260), @initial_file_name nvarchar(260),
                                      @audit_record_offset bigint) returns table as
-- missing source code
go

create function sys.fn_get_sql(@handle varbinary(64)) returns table as
-- missing source code
go

create function sys.fn_getproviderstring(@server sysname) returns nvarchar(4000) as
-- missing source code
go

create function sys.fn_getserverportfromproviderstring(@provider_str sysname) returns nvarchar(4000) as
-- missing source code
go

create function sys.fn_hadr_backup_is_preferred_replica(@database_name sysname) returns bit as
-- missing source code
go

create function sys.fn_hadr_distributed_ag_database_replica(@lag_id uniqueidentifier, @database_id uniqueidentifier) returns table as
-- missing source code
go

create function sys.fn_hadr_distributed_ag_replica(@lag_id uniqueidentifier, @replica_id uniqueidentifier) returns table as
-- missing source code
go

create function sys.fn_hadr_is_primary_replica(@database_name sysname) returns bit as
-- missing source code
go

create function sys.fn_hadr_is_same_replica(@lag_id uniqueidentifier, @lag_replica_id uniqueidentifier,
                                            @ag_replica_id uniqueidentifier) returns bit as
-- missing source code
go

create function sys.fn_helpcollations() returns table as
-- missing source code
go

create function sys.fn_helpdatatypemap(@source_dbms sysname, @source_version sysname, @source_type sysname,
                                       @destination_dbms sysname, @destination_version sysname,
                                       @destination_type sysname, @defaults_only bit) returns table as
-- missing source code
go

create function sys.fn_isrolemember(@mode int, @login sysname, @tranpubid int) returns int as
-- missing source code
go

create function sys.fn_ledger_retrieve_digests_from_url(@path nvarchar(4000)) returns table as
-- missing source code
go

create function sys.fn_listextendedproperty(@name sysname, @level0type varchar(128), @level0name sysname,
                                            @level1type varchar(128), @level1name sysname, @level2type varchar(128),
                                            @level2name sysname) returns table as
-- missing source code
go

create function sys.fn_my_permissions(@entity sysname, @class nvarchar(60)) returns table as
-- missing source code
go

create function sys.fn_numberOf1InBinaryAfterLoc(@byte binary, @loc int) returns int as
-- missing source code
go

create function sys.fn_numberOf1InVarBinary(@bm varbinary(128)) returns int as
-- missing source code
go

create function sys.fn_repladjustcolumnmap(@objid int, @total_col int, @inmap varbinary(4000)) returns varbinary(4000) as
-- missing source code
go

create function sys.fn_repldecryptver4(@password nvarchar(524)) returns nvarchar(524) as
-- missing source code
go

create function sys.fn_replformatdatetime(@datetime datetime) returns nvarchar(50) as
-- missing source code
go

create function sys.fn_replgetcolidfrombitmap(@columns binary(32)) returns table as
-- missing source code
go

create function sys.fn_replgetparsedddlcmd(@ddlcmd nvarchar(max), @FirstToken sysname, @objectType sysname,
                                           @dbname sysname, @owner sysname, @objname sysname,
                                           @targetobject nvarchar(512)) returns nvarchar(max) as
-- missing source code
go

create function sys.fn_replp2pversiontotranid(@varbin varbinary(32)) returns nvarchar(40) as
-- missing source code
go

create function sys.fn_replreplacesinglequote(@pstrin nvarchar(max)) returns nvarchar(max) as
-- missing source code
go

create function sys.fn_replreplacesinglequoteplusprotectstring(@pstrin nvarchar(4000)) returns nvarchar(4000) as
-- missing source code
go

create function sys.fn_repluniquename(@guid uniqueidentifier, @prefix1 sysname, @prefix2 sysname, @prefix3 sysname,
                                      @prefix4 sysname) returns nvarchar(100) as
-- missing source code
go

create function sys.fn_replvarbintoint(@varbin varbinary(32)) returns int as
-- missing source code
go

create function sys.fn_servershareddrives() returns table as
-- missing source code
go

create function sys.fn_sqlagent_job_history(@job_id uniqueidentifier, @step_id int) returns table as
-- missing source code
go

create function sys.fn_sqlagent_jobs(@job_id uniqueidentifier) returns table as
-- missing source code
go

create function sys.fn_sqlagent_jobsteps(@job_id uniqueidentifier, @step_id int) returns table as
-- missing source code
go

create function sys.fn_sqlagent_jobsteps_logs(@step_uid uniqueidentifier) returns table as
-- missing source code
go

create function sys.fn_sqlagent_subsystems() returns table as
-- missing source code
go

create function sys.fn_sqlvarbasetostr(@ssvar sql_variant) returns nvarchar(max) as
-- missing source code
go

create function sys.fn_stmt_sql_handle_from_sql_stmt(@query_sql_text nvarchar(max), @query_param_type tinyint) returns table as
-- missing source code
go

create function sys.fn_trace_geteventinfo(@handle int) returns table as
-- missing source code
go

create function sys.fn_trace_getfilterinfo(@handle int) returns table as
-- missing source code
go

create function sys.fn_trace_getinfo(@handle int) returns table as
-- missing source code
go

create function sys.fn_trace_gettable(@filename nvarchar(4000), @numfiles int) returns table as
-- missing source code
go

create function sys.fn_translate_permissions(@level nvarchar(60), @perms varbinary(16)) returns table as
-- missing source code
go

create function sys.fn_validate_plan_guide(@plan_guide_id int) returns table as
-- missing source code
go

create function sys.fn_varbintohexstr(@pbinin varbinary(max)) returns nvarchar(max) as
-- missing source code
go

create function sys.fn_varbintohexsubstring(@fsetprefix bit, @pbinin varbinary(max), @startoffset int,
                                            @cbytesin int) returns nvarchar(max) as
-- missing source code
go

create function sys.fn_virtualfilestats(@DatabaseId int, @FileId int) returns table as
-- missing source code
go

create function sys.fn_virtualservernodes() returns table as
-- missing source code
go

create function sys.fn_xcs_get_file_rowcount(@object_id int, @container_guid uniqueidentifier, @generation_id bigint,
                                             @container_path nvarchar(4000), @relative_path nvarchar(4000),
                                             @etag nvarchar(4000), @token nvarchar(4000)) returns table as
-- missing source code
go

create function sys.fn_xe_file_target_read_file(@path nvarchar(260), @mdpath nvarchar(260),
                                                @initial_file_name nvarchar(260),
                                                @initial_offset bigint) returns table as
-- missing source code
go

create function sys.fn_yukonsecuritymodelrequired(@username sysname) returns bit as
-- missing source code
go

create procedure sys.sp_AddFunctionalUnitToComponent() as
-- missing source code
go

create procedure sys.sp_FuzzyLookupTableMaintenanceInstall(@etiTableName nvarchar(1024)) as
-- missing source code
go

create procedure sys.sp_FuzzyLookupTableMaintenanceInvoke(@etiTableName nvarchar(1024)) as
-- missing source code
go

create procedure sys.sp_FuzzyLookupTableMaintenanceUninstall(@etiTableName nvarchar(1024)) as
-- missing source code
go

create procedure sys.sp_IHScriptIdxFile(@article_id int) as
-- missing source code
go

create procedure sys.sp_IHScriptSchFile(@article_id int) as
-- missing source code
go

create procedure sys.sp_IHValidateRowFilter(@publisher sysname, @owner sysname, @table sysname, @columnmask binary(128),
                                            @rowfilter nvarchar(max)) as
-- missing source code
go

create procedure sys.sp_IHXactSetJob(@publisher sysname, @enabled bit, @interval int, @threshold int, @LRinterval int,
                                     @LRthreshold int) as
-- missing source code
go

create procedure sys.sp_IH_LR_GetCacheData(@publisher sysname) as
-- missing source code
go

create procedure sys.sp_IHadd_sync_command(@publisher_id smallint, @publisher_db sysname, @xact_id varbinary(16),
                                           @xact_seqno varbinary(16), @originator sysname, @originator_db sysname,
                                           @article_id int, @command_id int, @type int, @partial_command bit,
                                           @command varbinary(1024), @publisher sysname) as
-- missing source code
go

create procedure sys.sp_IHarticlecolumn(@publication sysname, @article sysname, @column sysname, @operation nvarchar(4),
                                        @refresh_synctran_procs bit, @ignore_distributor bit, @change_active int,
                                        @force_invalidate_snapshot bit, @force_reinit_subscription bit,
                                        @publisher sysname, @publisher_type sysname, @publisher_dbms sysname,
                                        @publisher_version sysname) as
-- missing source code
go

create procedure sys.sp_IHget_loopback_detection(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                 @subscriber sysname, @subscriber_db sysname) as
-- missing source code
go

create procedure sys.sp_MSCleanupForPullReinit(@publication sysname, @publisher_db sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_MSFixSubColumnBitmaps(@artid uniqueidentifier, @bm varbinary(128)) as
-- missing source code
go

create procedure sys.sp_MSGetCurrentPrincipal(@db_name sysname, @current_principal sysname) as
-- missing source code
go

create procedure sys.sp_MSGetServerProperties() as
-- missing source code
go

create procedure sys.sp_MSIfExistsSubscription(@publisher sysname, @publisher_db sysname, @publication sysname,
                                               @type int) as
-- missing source code
go

create procedure sys.sp_MSIsContainedAGSession() as
-- missing source code
go

create procedure sys.sp_MSNonSQLDDL(@qual_source_object nvarchar(540), @pubid uniqueidentifier, @columnName sysname,
                                    @schemasubtype int) as
-- missing source code
go

create procedure sys.sp_MSNonSQLDDLForSchemaDDL(@artid uniqueidentifier, @pubid uniqueidentifier,
                                                @ddlcmd nvarchar(max)) as
-- missing source code
go

create procedure sys.sp_MSSQLDMO70_version() as
-- missing source code
go

create procedure sys.sp_MSSQLDMO80_version() as
-- missing source code
go

create procedure sys.sp_MSSQLDMO90_version() as
-- missing source code
go

create procedure sys.sp_MSSQLOLE65_version() as
-- missing source code
go

create procedure sys.sp_MSSQLOLE_version() as
-- missing source code
go

create procedure sys.sp_MSSetServerProperties(@auto_start int) as
-- missing source code
go

create procedure sys.sp_MSSharedFixedDisk() as
-- missing source code
go

create procedure sys.sp_MS_marksystemobject(@objname nvarchar(517), @namespace varchar(10)) as
-- missing source code
go

create procedure sys.sp_MS_replication_installed() as
-- missing source code
go

create procedure sys.sp_MSacquireHeadofQueueLock(@process_name sysname, @queue_timeout int, @no_result bit,
                                                 @return_immediately bit, @DbPrincipal sysname) as
-- missing source code
go

create procedure sys.sp_MSacquireSlotLock(@process_name sysname, @concurrent_max int, @queue_timeout int,
                                          @return_immediately bit, @DbPrincipal sysname) as
-- missing source code
go

create procedure sys.sp_MSacquireserverresourcefordynamicsnapshot(@publication sysname, @max_concurrent_dynamic_snapshots int) as
-- missing source code
go

create procedure sys.sp_MSacquiresnapshotdeliverysessionlock() as
-- missing source code
go

create procedure sys.sp_MSactivate_auto_sub(@publication sysname, @article sysname, @status sysname,
                                            @skipobjectactivation int, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_MSactivatelogbasedarticleobject(@qualified_logbased_object_name nvarchar(517)) as
-- missing source code
go

create procedure sys.sp_MSactivateprocedureexecutionarticleobject(@qualified_procedure_execution_object_name nvarchar(517),
                                                                  @is_repl_serializable_only bit) as
-- missing source code
go

create procedure sys.sp_MSadd_anonymous_agent(@publisher_id int, @publisher_db sysname, @publication sysname,
                                              @subscriber_db sysname, @subscriber_name sysname,
                                              @anonymous_subid uniqueidentifier, @agent_id int, @reinitanon bit) as
-- missing source code
go

create procedure sys.sp_MSadd_article(@publisher sysname, @publisher_db sysname, @publication sysname, @article sysname,
                                      @article_id int, @destination_object sysname, @source_object sysname,
                                      @description nvarchar(255), @source_owner sysname, @destination_owner sysname,
                                      @internal sysname) as
-- missing source code
go

create procedure sys.sp_MSadd_compensating_cmd(@orig_srv sysname, @orig_db sysname, @command nvarchar(max),
                                               @article_id int, @publication_id int, @cmdstate bit, @mode int,
                                               @setprefix bit) as
-- missing source code
go

create procedure sys.sp_MSadd_distribution_agent(@name sysname, @publisher_id smallint, @publisher_db sysname,
                                                 @publication sysname, @subscriber_id smallint, @subscriber_db sysname,
                                                 @subscription_type int, @local_job bit, @frequency_type int,
                                                 @frequency_interval int, @frequency_relative_interval int,
                                                 @frequency_recurrence_factor int, @frequency_subday int,
                                                 @frequency_subday_interval int, @active_start_time_of_day int,
                                                 @active_end_time_of_day int, @active_start_date int,
                                                 @active_end_date int, @retryattempts int, @retrydelay int,
                                                 @command nvarchar(4000), @agent_id int, @distribution_jobid binary(16),
                                                 @update_mode int, @offloadagent bit, @offloadserver sysname,
                                                 @dts_package_name sysname, @dts_package_password nvarchar(524),
                                                 @dts_package_location int, @subscriber_security_mode smallint,
                                                 @subscriber_login sysname, @subscriber_password nvarchar(524),
                                                 @job_login nvarchar(257), @job_password sysname, @internal sysname,
                                                 @subscriber_provider sysname, @subscriber_datasrc nvarchar(4000),
                                                 @subscriber_location nvarchar(4000),
                                                 @subscriber_provider_string nvarchar(4000),
                                                 @subscriber_catalog sysname) as
-- missing source code
go

create procedure sys.sp_MSadd_distribution_history(@agent_id int, @runstatus int, @comments nvarchar(max),
                                                   @xact_seqno binary(16), @delivered_transactions int,
                                                   @delivered_commands int, @delivery_rate float, @log_error bit,
                                                   @perfmon_increment bit, @xactseq varbinary(16), @command_id int,
                                                   @update_existing_row bit, @updateable_row bit, @do_raiserror bit) as
-- missing source code
go

create procedure sys.sp_MSadd_dynamic_snapshot_location(@publication sysname, @partition_id int,
                                                        @dynsnap_location nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_MSadd_filteringcolumn(@pubid uniqueidentifier, @tablenick int, @column_name sysname) as
-- missing source code
go

create procedure sys.sp_MSadd_log_shipping_error_detail(@agent_id uniqueidentifier, @agent_type tinyint,
                                                        @session_id int, @database sysname, @sequence_number int,
                                                        @message nvarchar(4000), @source nvarchar(4000),
                                                        @help_url nvarchar(4000)) as
-- missing source code
go

create procedure sys.sp_MSadd_log_shipping_history_detail(@agent_id uniqueidentifier, @agent_type tinyint,
                                                          @session_id int, @session_status tinyint, @database sysname,
                                                          @last_processed_file_name nvarchar(500),
                                                          @message nvarchar(4000)) as
-- missing source code
go

create procedure sys.sp_MSadd_logreader_agent(@name nvarchar(100), @publisher sysname, @publisher_db sysname,
                                              @publication sysname, @local_job bit, @job_existing bit,
                                              @job_id binary(16), @publisher_security_mode smallint,
                                              @publisher_login sysname, @publisher_password nvarchar(524),
                                              @job_login nvarchar(257), @job_password sysname, @publisher_type sysname,
                                              @internal sysname, @publisher_engine_edition int) as
-- missing source code
go

create procedure sys.sp_MSadd_logreader_history(@agent_id int, @runstatus int, @comments nvarchar(4000),
                                                @xact_seqno varbinary(16), @delivery_time int,
                                                @delivered_transactions int, @delivered_commands int,
                                                @delivery_latency int, @log_error bit, @perfmon_increment bit,
                                                @update_existing_row bit, @do_raiserror bit, @updateable_row bit) as
-- missing source code
go

create procedure sys.sp_MSadd_merge_agent(@name sysname, @publisher sysname, @publisher_db sysname,
                                          @publication sysname, @subscriber sysname, @subscriber_db sysname,
                                          @local_job bit, @frequency_type int, @frequency_interval int,
                                          @frequency_relative_interval int, @frequency_recurrence_factor int,
                                          @frequency_subday int, @frequency_subday_interval int,
                                          @active_start_time_of_day int, @active_end_time_of_day int,
                                          @active_start_date int, @active_end_date int,
                                          @optional_command_line nvarchar(255), @merge_jobid binary(16),
                                          @offloadagent bit, @offloadserver sysname, @subscription_type int,
                                          @hostname sysname, @subscriber_security_mode smallint,
                                          @subscriber_login sysname, @subscriber_password nvarchar(524),
                                          @publisher_security_mode smallint, @publisher_login sysname,
                                          @publisher_password nvarchar(524), @job_login nvarchar(257),
                                          @job_password sysname, @internal sysname, @publisher_engine_edition int) as
-- missing source code
go

create procedure sys.sp_MSadd_merge_anonymous_agent(@publisher_id smallint, @publisher_db sysname, @publication sysname,
                                                    @subscriber_db sysname, @subscriber_name sysname,
                                                    @subid uniqueidentifier, @first_anonymous int,
                                                    @subscriber_version int, @publisher_engine_edition int) as
-- missing source code
go

create procedure sys.sp_MSadd_merge_history(@agent_id int, @runstatus int, @comments nvarchar(1000), @delivery_time int,
                                            @download_inserts int, @download_updates int, @download_deletes int,
                                            @download_conflicts int, @upload_inserts int, @upload_updates int,
                                            @upload_deletes int, @upload_conflicts int, @log_error bit,
                                            @perfmon_increment bit, @update_existing_row bit, @updateable_row bit,
                                            @do_raiserror bit, @called_by_nonlogged_shutdown_detection_agent bit,
                                            @session_id_override int) as
-- missing source code
go

create procedure sys.sp_MSadd_merge_history90(@session_id int, @agent_id int, @runstatus int, @comments nvarchar(1000),
                                              @update_existing_row bit, @updateable_row bit, @log_error bit,
                                              @update_stats bit, @phase_id int, @article_name sysname,
                                              @article_inserts int, @article_updates int, @article_deletes int,
                                              @article_conflicts int, @article_rows_retried int,
                                              @article_percent_complete decimal(5, 2), @article_estimated_changes int,
                                              @article_relative_cost decimal(12, 2), @session_duration int,
                                              @delivery_time int, @upload_time int, @download_time int,
                                              @schema_change_time int, @prepare_snapshot_time int,
                                              @delivery_rate decimal(12, 2), @time_remaining int,
                                              @session_percent_complete decimal(5, 2), @session_upload_inserts int,
                                              @session_upload_updates int, @session_upload_deletes int,
                                              @session_upload_conflicts int, @session_upload_rows_retried int,
                                              @session_download_inserts int, @session_download_updates int,
                                              @session_download_deletes int, @session_download_conflicts int,
                                              @session_download_rows_retried int, @session_schema_changes int,
                                              @session_bulk_inserts int, @session_metadata_rows_cleanedup int,
                                              @session_estimated_upload_changes int,
                                              @session_estimated_download_changes int, @connection_type int,
                                              @subid uniqueidentifier, @info_filter int) as
-- missing source code
go

create procedure sys.sp_MSadd_merge_subscription(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                 @subscriber sysname, @subscriber_db sysname,
                                                 @subscription_type tinyint, @sync_type tinyint, @status tinyint,
                                                 @frequency_type int, @frequency_interval int,
                                                 @frequency_relative_interval int, @frequency_recurrence_factor int,
                                                 @frequency_subday int, @frequency_subday_interval int,
                                                 @active_start_time_of_day int, @active_end_time_of_day int,
                                                 @active_start_date int, @active_end_date int,
                                                 @optional_command_line nvarchar(4000), @agent_name sysname,
                                                 @merge_jobid binary(16), @offloadagent bit, @offloadserver sysname,
                                                 @hostname sysname, @description nvarchar(255), @subid uniqueidentifier,
                                                 @internal sysname, @publisher_engine_edition int) as
-- missing source code
go

create procedure sys.sp_MSadd_mergereplcommand(@publication sysname, @article sysname, @schematype int,
                                               @schematext nvarchar(2000), @tablename sysname) as
-- missing source code
go

create procedure sys.sp_MSadd_mergesubentry_indistdb(@publisher_id smallint, @publisher sysname, @publisher_db sysname,
                                                     @publication sysname, @subscriber sysname, @subscriber_db sysname,
                                                     @subscription_type tinyint, @sync_type tinyint, @status tinyint,
                                                     @description nvarchar(255), @subid uniqueidentifier,
                                                     @subscriber_version int) as
-- missing source code
go

create procedure sys.sp_MSadd_publication(@publisher sysname, @publisher_db sysname, @publication sysname,
                                          @publication_id int, @publication_type int, @independent_agent bit,
                                          @immediate_sync bit, @allow_push bit, @allow_pull bit, @allow_anonymous bit,
                                          @snapshot_agent nvarchar(100), @logreader_agent nvarchar(100),
                                          @description nvarchar(255), @retention int, @vendor_name nvarchar(100),
                                          @sync_method int, @allow_subscription_copy bit, @thirdparty_options int,
                                          @allow_queued_tran bit, @queue_type int, @publisher_type sysname,
                                          @options int, @retention_period_unit tinyint, @publisher_engine_edition int,
                                          @allow_initialize_from_backup bit) as
-- missing source code
go

create procedure sys.sp_MSadd_qreader_agent(@name nvarchar(100), @agent_id int, @agent_jobid binary(16),
                                            @job_login nvarchar(257), @job_password sysname, @internal sysname) as
-- missing source code
go

create procedure sys.sp_MSadd_qreader_history(@agent_id int, @pubid int, @runstatus int, @comments nvarchar(1000),
                                              @transaction_id nvarchar(40), @transaction_status int,
                                              @transactions_processed int, @commands_processed int,
                                              @seconds_elapsed int, @subscriber sysname, @subscriberdb sysname,
                                              @perfmon_increment bit, @log_error bit, @update_existing_row bit,
                                              @do_raiserror bit) as
-- missing source code
go

create procedure sys.sp_MSadd_repl_alert(@agent_type int, @agent_id int, @error_id int, @alert_error_code int,
                                         @xact_seqno varbinary(16), @command_id int, @publisher sysname,
                                         @publisher_db sysname, @subscriber sysname, @subscriber_db sysname,
                                         @alert_error_text nvarchar(max)) as
-- missing source code
go

create procedure sys.sp_MSadd_repl_command(@publisher_id smallint, @publisher_db sysname, @xact_id varbinary(16),
                                           @xact_seqno varbinary(16), @originator sysname, @originator_db sysname,
                                           @article_id int, @command_id int, @type int, @partial_command bit,
                                           @command varbinary(1024), @publisher sysname) as
-- missing source code
go

create procedure sys.sp_MSadd_repl_commands27hp(@publisher_id smallint, @publisher_db sysname, @data varbinary(1575),
                                                @1data varbinary(1575), @2data varbinary(1575), @3data varbinary(1575),
                                                @4data varbinary(1575), @5data varbinary(1575), @6data varbinary(1575),
                                                @7data varbinary(1575), @8data varbinary(1575), @9data varbinary(1575),
                                                @10data varbinary(1575), @11data varbinary(1575),
                                                @12data varbinary(1575), @13data varbinary(1575),
                                                @14data varbinary(1575), @15data varbinary(1575),
                                                @16data varbinary(1575), @17data varbinary(1575),
                                                @18data varbinary(1575), @19data varbinary(1575),
                                                @20data varbinary(1575), @21data varbinary(1575),
                                                @22data varbinary(1575), @23data varbinary(1575),
                                                @24data varbinary(1575), @25data varbinary(1575),
                                                @26data varbinary(1575)) as
-- missing source code
go

create procedure sys.sp_MSadd_repl_error(@id int, @error_type_id int, @source_type_id int, @source_name sysname,
                                         @error_code sysname, @error_text nvarchar(max), @session_id int,
                                         @add_event_log int, @event_log_context nvarchar(max), @map_source_type bit) as
-- missing source code
go

create procedure sys.sp_MSadd_replcmds_mcit(@publisher_database_id int, @publisher_id smallint, @publisher_db sysname,
                                            @data varbinary(1595), @1data varbinary(1595), @2data varbinary(1595),
                                            @3data varbinary(1595), @4data varbinary(1595), @5data varbinary(1595),
                                            @6data varbinary(1595), @7data varbinary(1595), @8data varbinary(1595),
                                            @9data varbinary(1595), @10data varbinary(1595), @11data varbinary(1595),
                                            @12data varbinary(1595), @13data varbinary(1595), @14data varbinary(1595),
                                            @15data varbinary(1595), @16data varbinary(1595), @17data varbinary(1595),
                                            @18data varbinary(1595), @19data varbinary(1595), @20data varbinary(1595),
                                            @21data varbinary(1595), @22data varbinary(1595), @23data varbinary(1595),
                                            @24data varbinary(1595), @25data varbinary(1595),
                                            @26data varbinary(1595)) as
-- missing source code
go

create procedure sys.sp_MSadd_replmergealert(@agent_type int, @agent_id int, @error_id int, @alert_error_code int,
                                             @publisher sysname, @publisher_db sysname, @publication sysname,
                                             @publication_type int, @subscriber sysname, @subscriber_db sysname,
                                             @article sysname, @destination_object sysname, @source_object sysname,
                                             @alert_error_text nvarchar(max)) as
-- missing source code
go

create procedure sys.sp_MSadd_snapshot_agent(@name nvarchar(100), @publisher sysname, @publisher_db sysname,
                                             @publication sysname, @publication_type int, @local_job bit, @freqtype int,
                                             @freqinterval int, @freqsubtype int, @freqsubinterval int,
                                             @freqrelativeinterval int, @freqrecurrencefactor int, @activestartdate int,
                                             @activeenddate int, @activestarttimeofday int, @activeendtimeofday int,
                                             @command nvarchar(4000), @job_existing bit, @snapshot_jobid binary(16),
                                             @publisher_security_mode smallint, @publisher_login sysname,
                                             @publisher_password nvarchar(524), @job_login nvarchar(257),
                                             @job_password sysname, @publisher_type sysname, @internal sysname) as
-- missing source code
go

create procedure sys.sp_MSadd_snapshot_history(@agent_id int, @runstatus int, @comments nvarchar(1000),
                                               @delivered_transactions int, @delivered_commands int, @log_error bit,
                                               @perfmon_increment bit, @update_existing_row bit, @do_raiserror bit,
                                               @start_time_string nvarchar(25), @duration int) as
-- missing source code
go

create procedure sys.sp_MSadd_subscriber_info(@publisher sysname, @subscriber sysname, @type tinyint, @login sysname,
                                              @password nvarchar(524), @commit_batch_size int, @status_batch_size int,
                                              @flush_frequency int, @frequency_type int, @frequency_interval int,
                                              @frequency_relative_interval int, @frequency_recurrence_factor int,
                                              @frequency_subday int, @frequency_subday_interval int,
                                              @active_start_time_of_day int, @active_end_time_of_day int,
                                              @active_start_date int, @active_end_date int, @retryattempts int,
                                              @retrydelay int, @description nvarchar(255), @security_mode int,
                                              @encrypted_password bit, @internal sysname) as
-- missing source code
go

create procedure sys.sp_MSadd_subscriber_schedule(@publisher sysname, @subscriber sysname, @agent_type smallint,
                                                  @frequency_type int, @frequency_interval int,
                                                  @frequency_relative_interval int, @frequency_recurrence_factor int,
                                                  @frequency_subday int, @frequency_subday_interval int,
                                                  @active_start_time_of_day int, @active_end_time_of_day int,
                                                  @active_start_date int, @active_end_date int) as
-- missing source code
go

create procedure sys.sp_MSadd_subscription(@publisher sysname, @publisher_db sysname, @subscriber sysname,
                                           @article_id int, @subscriber_db sysname, @status tinyint,
                                           @subscription_seqno varbinary(16), @publication sysname, @article sysname,
                                           @subscription_type tinyint, @sync_type tinyint, @snapshot_seqno_flag bit,
                                           @frequency_type int, @frequency_interval int,
                                           @frequency_relative_interval int, @frequency_recurrence_factor int,
                                           @frequency_subday int, @frequency_subday_interval int,
                                           @active_start_time_of_day int, @active_end_time_of_day int,
                                           @active_start_date int, @active_end_date int,
                                           @optional_command_line nvarchar(4000), @update_mode tinyint,
                                           @loopback_detection bit, @distribution_jobid binary(16), @offloadagent bit,
                                           @offloadserver sysname, @dts_package_name sysname,
                                           @dts_package_password nvarchar(524), @dts_package_location int,
                                           @distribution_job_name sysname, @internal sysname,
                                           @publisher_engine_edition int, @nosync_type tinyint) as
-- missing source code
go

create procedure sys.sp_MSadd_subscription_3rd(@publisher sysname, @publisher_db sysname, @publication sysname,
                                               @subscriber sysname, @subscriber_db sysname, @status tinyint,
                                               @subscription_type tinyint, @sync_type tinyint, @frequency_type int,
                                               @frequency_interval int, @frequency_relative_interval int,
                                               @frequency_recurrence_factor int, @frequency_subday int,
                                               @frequency_subday_interval int, @active_start_time_of_day int,
                                               @active_end_time_of_day int, @active_start_date int,
                                               @active_end_date int, @distribution_jobid binary(8)) as
-- missing source code
go

create procedure sys.sp_MSadd_tracer_history(@tracer_id int) as
-- missing source code
go

create procedure sys.sp_MSadd_tracer_token(@publisher sysname, @publisher_db sysname, @publication sysname,
                                           @tracer_id int, @subscribers_found bit) as
-- missing source code
go

create procedure sys.sp_MSaddanonymousreplica(@publication sysname, @publisher sysname, @publisherDB sysname,
                                              @anonymous int, @sync_type int, @preexists bit) as
-- missing source code
go

create procedure sys.sp_MSadddynamicsnapshotjobatdistributor(@regular_snapshot_jobid uniqueidentifier,
                                                             @dynamic_filter_login sysname,
                                                             @dynamic_filter_hostname sysname,
                                                             @dynamic_snapshot_location nvarchar(255),
                                                             @dynamic_snapshot_jobname nvarchar(128),
                                                             @dynamic_snapshot_jobid uniqueidentifier,
                                                             @dynamic_snapshot_job_step_uid uniqueidentifier,
                                                             @freqtype int, @freqinterval int, @freqsubtype int,
                                                             @freqsubinterval int, @freqrelativeinterval int,
                                                             @freqrecurrencefactor int, @activestartdate int,
                                                             @activeenddate int, @activestarttimeofday int,
                                                             @activeendtimeofday int, @dynamic_snapshot_agent_id int,
                                                             @partition_id int) as
-- missing source code
go

create procedure sys.sp_MSaddguidcolumn(@source_owner sysname, @source_table sysname) as
-- missing source code
go

create procedure sys.sp_MSaddguidindex(@publication sysname, @source_owner sysname, @source_table sysname) as
-- missing source code
go

create procedure sys.sp_MSaddinitialarticle(@article sysname, @artid uniqueidentifier, @pubid uniqueidentifier,
                                            @nickname int, @column_tracking int, @status int, @pre_creation_command int,
                                            @resolver_clsid nvarchar(255), @insert_proc nvarchar(255),
                                            @update_proc nvarchar(255), @select_proc nvarchar(255),
                                            @destination_object sysname, @missing_count int,
                                            @missing_cols varbinary(128), @article_resolver nvarchar(255),
                                            @resolver_info nvarchar(517), @filter_clause nvarchar(2000),
                                            @excluded_count int, @excluded_cols varbinary(128),
                                            @destination_owner sysname, @identity_support int,
                                            @verify_resolver_signature int, @fast_multicol_updateproc bit,
                                            @published_in_tran_pub bit, @logical_record_level_conflict_detection bit,
                                            @logical_record_level_conflict_resolution bit, @partition_options tinyint,
                                            @processing_order int, @upload_options tinyint, @delete_tracking bit,
                                            @compensate_for_errors bit, @pub_identity_range bigint,
                                            @identity_range bigint, @threshold int, @stream_blob_columns bit,
                                            @preserve_rowguidcol bit) as
-- missing source code
go

create procedure sys.sp_MSaddinitialpublication(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                @description nvarchar(255), @pubid uniqueidentifier, @retention int,
                                                @sync_mode int, @allow_push int, @allow_pull int, @allow_anonymous int,
                                                @conflict_logging int, @status int, @snapshot_ready int,
                                                @enabled_for_internet int, @publication_type int,
                                                @conflict_retention int, @allow_subscription_copy int,
                                                @allow_synctoalternate int, @backward_comp_level int,
                                                @replicate_ddl int, @retention_period_unit tinyint,
                                                @replnickname binary(6), @generation_leveling_threshold int,
                                                @automatic_reinitialization_policy bit) as
-- missing source code
go

create procedure sys.sp_MSaddinitialschemaarticle(@name sysname, @destination_object sysname,
                                                  @destination_owner sysname, @artid uniqueidentifier,
                                                  @pubid uniqueidentifier, @pre_creation_command tinyint, @status int,
                                                  @type tinyint) as
-- missing source code
go

create procedure sys.sp_MSaddinitialsubscription(@pubid uniqueidentifier, @subid uniqueidentifier,
                                                 @replicastate uniqueidentifier, @subscriber sysname,
                                                 @subscriber_db sysname, @subscriber_priority real,
                                                 @subscriber_type tinyint, @subscription_type int, @sync_type tinyint,
                                                 @publication sysname, @distributor sysname, @replica_version int) as
-- missing source code
go

create procedure sys.sp_MSaddlightweightmergearticle(@pubid uniqueidentifier, @article_name sysname,
                                                     @artid uniqueidentifier, @tablenick int,
                                                     @destination_owner sysname, @identity_support int,
                                                     @destination_object sysname, @column_tracking bit,
                                                     @upload_options tinyint, @well_partitioned bit, @status int,
                                                     @processing_order int, @delete_tracking bit,
                                                     @compensate_for_errors bit, @stream_blob_columns bit) as
-- missing source code
go

create procedure sys.sp_MSaddmergedynamicsnapshotjob(@publication sysname, @dynamic_filter_login sysname,
                                                     @dynamic_filter_hostname sysname,
                                                     @dynamic_snapshot_location nvarchar(255),
                                                     @dynamic_snapshot_jobname sysname,
                                                     @dynamic_snapshot_jobid uniqueidentifier,
                                                     @dynamic_job_step_uid uniqueidentifier, @frequency_type int,
                                                     @frequency_interval int, @frequency_subday int,
                                                     @frequency_subday_interval int, @frequency_relative_interval int,
                                                     @frequency_recurrence_factor int, @active_start_date int,
                                                     @active_end_date int, @active_start_time_of_day int,
                                                     @active_end_time_of_day int, @dynamic_snapshot_agentid int,
                                                     @ignore_select bit) as
-- missing source code
go

create procedure sys.sp_MSaddmergetriggers(@source_table nvarchar(517), @table_owner sysname, @column_tracking int,
                                           @recreate_repl_views bit) as
-- missing source code
go

create procedure sys.sp_MSaddmergetriggers_from_template(@tablenickstr nvarchar(15), @source_table nvarchar(270),
                                                         @table_owner sysname, @rgcol sysname, @column_tracking int,
                                                         @trigger_type tinyint, @viewname sysname, @tsview sysname,
                                                         @trigname sysname, @genhistory_viewname sysname,
                                                         @replnick binary(6),
                                                         @max_colv_size_in_bytes_str nvarchar(15)) as
-- missing source code
go

create procedure sys.sp_MSaddmergetriggers_internal(@source_table sysname, @table_owner sysname, @column_tracking int,
                                                    @trigger_type tinyint, @viewname sysname, @tsview sysname,
                                                    @trigname sysname, @current_mappings_viewname sysname,
                                                    @past_mappings_viewname sysname, @genhistory_viewname sysname) as
-- missing source code
go

create procedure sys.sp_MSaddpeerlsn(@originator sysname, @originator_db sysname, @originator_publication sysname,
                                     @originator_publication_id int, @originator_db_version int,
                                     @originator_lsn varbinary(10), @originator_version int, @originator_id int) as
-- missing source code
go

create procedure sys.sp_MSaddsubscriptionarticles(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                  @artid int, @article sysname, @dest_table sysname,
                                                  @dest_owner sysname) as
-- missing source code
go

create procedure sys.sp_MSadjust_pub_identity(@publisher sysname, @publisher_db sysname, @tablename sysname,
                                              @current_max bigint, @threshold int, @range bigint, @next_seed bigint,
                                              @pub_range bigint) as
-- missing source code
go

create procedure sys.sp_MSagent_retry_stethoscope() as
-- missing source code
go

create procedure sys.sp_MSagent_stethoscope(@heartbeat_interval int) as
-- missing source code
go

create procedure sys.sp_MSallocate_new_identity_range(@subid uniqueidentifier, @artid uniqueidentifier,
                                                      @range_type tinyint, @ranges_needed tinyint,
                                                      @range_begin numeric(38), @range_end numeric(38),
                                                      @next_range_begin numeric(38), @next_range_end numeric(38),
                                                      @publication sysname, @subscriber sysname,
                                                      @subscriber_db sysname) as
-- missing source code
go

create procedure sys.sp_MSalreadyhavegeneration(@genguid uniqueidentifier, @subscribernick binary(6),
                                                @compatlevel int) as
-- missing source code
go

create procedure sys.sp_MSanonymous_status(@agent_id int, @no_init_sync int, @last_xact_seqno varbinary(16)) as
-- missing source code
go

create procedure sys.sp_MSarticlecleanup(@pubid uniqueidentifier, @artid uniqueidentifier, @ignore_merge_metadata bit,
                                         @force_preserve_rowguidcol bit) as
-- missing source code
go

create procedure sys.sp_MSbrowsesnapshotfolder(@publisher sysname, @publisher_db sysname, @article_id int,
                                               @subscriber sysname, @subscriber_db sysname) as
-- missing source code
go

create procedure sys.sp_MScache_agent_parameter(@profile_name sysname, @parameter_name sysname,
                                                @parameter_value nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_MScdc_capture_job() as
-- missing source code
go

create procedure sys.sp_MScdc_cleanup_job() as
-- missing source code
go

create procedure sys.sp_MScdc_db_ddl_event(@EventData xml) as
-- missing source code
go

create procedure sys.sp_MScdc_ddl_event(@EventData xml) as
-- missing source code
go

create procedure sys.sp_MScdc_logddl(@source_object_id int, @ddl_command nvarchar(max), @ddl_lsn binary(10),
                                     @ddl_time nvarchar(1000), @commit_lsn binary(10), @source_column_id int,
                                     @fis_alter_column bit, @fis_drop_table bit, @fis_add_drop_column bit,
                                     @new_change_table_prefix sysname) as
-- missing source code
go

create procedure sys.sp_MSchange_article(@publisher sysname, @publisher_db sysname, @publication sysname,
                                         @article sysname, @article_id int, @property nvarchar(20),
                                         @value nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_MSchange_distribution_agent_properties(@publisher sysname, @publisher_db sysname,
                                                               @publication sysname, @subscriber sysname,
                                                               @subscriber_db sysname, @property sysname,
                                                               @value nvarchar(524)) as
-- missing source code
go

create procedure sys.sp_MSchange_feed_ddl_event(@EventData xml) as
-- missing source code
go

create procedure sys.sp_MSchange_logreader_agent_properties(@publisher sysname, @publisher_db sysname,
                                                            @publisher_security_mode int, @publisher_login sysname,
                                                            @publisher_password nvarchar(524), @job_login nvarchar(257),
                                                            @job_password sysname, @publisher_type sysname) as
-- missing source code
go

create procedure sys.sp_MSchange_merge_agent_properties(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                        @subscriber sysname, @subscriber_db sysname, @property sysname,
                                                        @value nvarchar(524)) as
-- missing source code
go

create procedure sys.sp_MSchange_mergearticle(@pubid uniqueidentifier, @artid uniqueidentifier, @property sysname,
                                              @value nvarchar(2000), @value_numeric int) as
-- missing source code
go

create procedure sys.sp_MSchange_mergepublication(@pubid uniqueidentifier, @property sysname, @value nvarchar(2000)) as
-- missing source code
go

create procedure sys.sp_MSchange_originatorid(@originator_node sysname, @originator_db sysname,
                                              @originator_publication sysname, @originator_publication_id int,
                                              @originator_db_version int, @originator_id int,
                                              @originator_version int) as
-- missing source code
go

create procedure sys.sp_MSchange_priority(@subid uniqueidentifier, @value nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_MSchange_publication(@publisher sysname, @publisher_db sysname, @publication sysname,
                                             @property sysname, @value nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_MSchange_retention(@pubid uniqueidentifier, @value nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_MSchange_retention_period_unit(@pubid uniqueidentifier, @value tinyint) as
-- missing source code
go

create procedure sys.sp_MSchange_snapshot_agent_properties(@publisher sysname, @publisher_db sysname,
                                                           @publication sysname, @frequency_type int,
                                                           @frequency_interval int, @frequency_subday int,
                                                           @frequency_subday_interval int,
                                                           @frequency_relative_interval int,
                                                           @frequency_recurrence_factor int, @active_start_date int,
                                                           @active_end_date int, @active_start_time_of_day int,
                                                           @active_end_time_of_day int,
                                                           @snapshot_job_name nvarchar(100),
                                                           @publisher_security_mode int, @publisher_login sysname,
                                                           @publisher_password nvarchar(524), @job_login nvarchar(257),
                                                           @job_password sysname, @publisher_type sysname) as
-- missing source code
go

create procedure sys.sp_MSchange_subscription_dts_info(@job_id varbinary(16), @dts_package_name sysname,
                                                       @dts_package_password nvarchar(524), @dts_package_location int,
                                                       @change_password bit) as
-- missing source code
go

create procedure sys.sp_MSchangearticleresolver(@article_resolver nvarchar(255), @resolver_clsid nvarchar(40),
                                                @artid uniqueidentifier, @resolver_info nvarchar(517)) as
-- missing source code
go

create procedure sys.sp_MSchangedynamicsnapshotjobatdistributor(@publisher sysname, @publisher_db sysname,
                                                                @publication sysname, @dynamic_filter_login sysname,
                                                                @dynamic_filter_hostname sysname, @frequency_type int,
                                                                @frequency_interval int, @frequency_subday int,
                                                                @frequency_subday_interval int,
                                                                @frequency_relative_interval int,
                                                                @frequency_recurrence_factor int,
                                                                @active_start_date int, @active_end_date int,
                                                                @active_start_time_of_day int,
                                                                @active_end_time_of_day int, @job_login nvarchar(257),
                                                                @job_password sysname) as
-- missing source code
go

create procedure sys.sp_MSchangedynsnaplocationatdistributor(@publisher sysname, @publisher_db sysname,
                                                             @publication sysname, @dynamic_filter_login sysname,
                                                             @dynamic_filter_hostname sysname,
                                                             @dynamic_snapshot_location nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_MSchangeobjectowner(@tablename sysname, @dest_owner sysname) as
-- missing source code
go

create procedure sys.sp_MScheckIsPubOfSub(@pubid uniqueidentifier, @subid uniqueidentifier, @pubOfSub bit) as
-- missing source code
go

create procedure sys.sp_MScheck_Jet_Subscriber(@subscriber sysname, @is_jet int, @Jet_datasource_path sysname) as
-- missing source code
go

create procedure sys.sp_MScheck_agent_instance(@application_name sysname, @agent_type int) as
-- missing source code
go

create procedure sys.sp_MScheck_dropobject(@objid int) as
-- missing source code
go

create procedure sys.sp_MScheck_logicalrecord_metadatamatch(@metadata_type tinyint, @parent_nickname int,
                                                            @parent_rowguid uniqueidentifier,
                                                            @logical_record_lineage varbinary(311),
                                                            @pubid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MScheck_merge_subscription_count(@publisher sysname, @publisher_engine_edition int,
                                                         @about_to_insert_new_subscription bit) as
-- missing source code
go

create procedure sys.sp_MScheck_pub_identity(@publisher sysname, @publisher_db sysname, @tablename sysname,
                                             @current_max bigint, @pub_range bigint, @threshold int, @range bigint,
                                             @next_seed bigint, @max_identity bigint) as
-- missing source code
go

create procedure sys.sp_MScheck_pull_access(@agent_id int, @agent_type int, @publication_id int,
                                            @raise_fatal_error bit) as
-- missing source code
go

create procedure sys.sp_MScheck_snapshot_agent(@publisher sysname, @publisher_db sysname, @publication sysname,
                                               @valid_agent_exists bit) as
-- missing source code
go

create procedure sys.sp_MScheck_subscription(@publication sysname, @pub_type int, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_MScheck_subscription_expiry(@pubid uniqueidentifier, @subscriber sysname,
                                                    @subscriber_db sysname, @expired bit) as
-- missing source code
go

create procedure sys.sp_MScheck_subscription_partition(@pubid uniqueidentifier, @subid uniqueidentifier,
                                                       @subscriber sysname, @subscriber_db sysname, @valid bit,
                                                       @force_delete_other bit, @subscriber_deleted sysname,
                                                       @subscriberdb_deleted sysname) as
-- missing source code
go

create procedure sys.sp_MScheck_tran_retention(@xact_seqno varbinary(16), @agent_id int) as
-- missing source code
go

create procedure sys.sp_MScheckexistsgeneration(@genguid uniqueidentifier, @gen bigint, @pubid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MScheckexistsrecguid(@recguid uniqueidentifier, @exists bit) as
-- missing source code
go

create procedure sys.sp_MScheckfailedprevioussync(@pubid uniqueidentifier, @last_sync_failed bit) as
-- missing source code
go

create procedure sys.sp_MScheckidentityrange(@pubid uniqueidentifier, @artname sysname, @next_seed bigint,
                                             @range bigint, @threshold int, @checkonly int) as
-- missing source code
go

create procedure sys.sp_MSchecksharedagentforpublication(@publisher_id int, @publisher_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_MSchecksnapshotstatus(@publication sysname) as
-- missing source code
go

create procedure sys.sp_MScleanup_agent_entry() as
-- missing source code
go

create procedure sys.sp_MScleanup_conflict(@pubid uniqueidentifier, @conflict_retention int) as
-- missing source code
go

create procedure sys.sp_MScleanup_publication_ADinfo(@name sysname, @database sysname) as
-- missing source code
go

create procedure sys.sp_MScleanup_subscription_distside_entry(@publisher sysname, @publisher_db sysname,
                                                              @publication sysname, @subscriber sysname,
                                                              @subscriber_db sysname) as
-- missing source code
go

create procedure sys.sp_MScleanupdynamicsnapshotfolder(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                       @dynamic_filter_login sysname, @dynamic_filter_hostname sysname,
                                                       @dynamic_snapshot_location nvarchar(260), @partition_id int) as
-- missing source code
go

create procedure sys.sp_MScleanupdynsnapshotvws() as
-- missing source code
go

create procedure sys.sp_MScleanupmergepublisher_internal() as
-- missing source code
go

create procedure sys.sp_MSclear_dynamic_snapshot_location(@publication sysname, @partition_id int, @deletefolder bit) as
-- missing source code
go

create procedure sys.sp_MSclearresetpartialsnapshotprogressbit(@agent_id int) as
-- missing source code
go

create procedure sys.sp_MScomputelastsentgen(@repid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MScomputemergearticlescreationorder(@publication sysname) as
-- missing source code
go

create procedure sys.sp_MScomputemergeunresolvedrefs(@publication sysname, @article sysname) as
-- missing source code
go

create procedure sys.sp_MSconflicttableexists(@pubid uniqueidentifier, @artid uniqueidentifier, @exists int) as
-- missing source code
go

create procedure sys.sp_MScreate_all_article_repl_views(@snapshot_application_finished bit) as
-- missing source code
go

create procedure sys.sp_MScreate_article_repl_views(@publication sysname) as
-- missing source code
go

create procedure sys.sp_MScreate_dist_tables() as
-- missing source code
go

create procedure sys.sp_MScreate_logical_record_views(@pubid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MScreate_sub_tables(@tran_sub_table bit, @property_table bit, @sqlqueue_table bit,
                                            @subscription_articles_table bit, @p2p_table bit) as
-- missing source code
go

create procedure sys.sp_MScreate_tempgenhistorytable(@pubid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MScreatedisabledmltrigger(@source_object sysname, @source_owner sysname) as
-- missing source code
go

create procedure sys.sp_MScreatedummygeneration(@pubid uniqueidentifier, @maxgen_whenadded bigint) as
-- missing source code
go

create procedure sys.sp_MScreateglobalreplica(@pubid uniqueidentifier, @subid uniqueidentifier,
                                              @replicastate uniqueidentifier, @replica_server sysname,
                                              @replica_db sysname, @replica_priority real, @subscriber_type tinyint,
                                              @subscription_type int, @datasource_type int,
                                              @datasource_path nvarchar(255), @replnick varbinary(6), @status int,
                                              @sync_type tinyint, @publication sysname, @distributor sysname,
                                              @replica_version int, @compatlevel int) as
-- missing source code
go

create procedure sys.sp_MScreatelightweightinsertproc(@pubid uniqueidentifier, @artid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MScreatelightweightmultipurposeproc(@pubid uniqueidentifier, @artid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MScreatelightweightprocstriggersconstraints(@pubid uniqueidentifier, @artid uniqueidentifier,
                                                                    @next_seed bigint, @range bigint, @threshold int) as
-- missing source code
go

create procedure sys.sp_MScreatelightweightupdateproc(@pubid uniqueidentifier, @artid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MScreatemergedynamicsnapshot(@publication sysname) as
-- missing source code
go

create procedure sys.sp_MScreateretry() as
-- missing source code
go

create procedure sys.sp_MSdbuseraccess(@mode nvarchar(10), @qual nvarchar(128)) as
-- missing source code
go

create procedure sys.sp_MSdbuserpriv(@mode nvarchar(10)) as
-- missing source code
go

create procedure sys.sp_MSdefer_check(@objname sysname, @objowner sysname) as
-- missing source code
go

create procedure sys.sp_MSdelete_tracer_history(@tracer_id int, @cutoff_date datetime, @num_records_removed int,
                                                @publication sysname, @publisher sysname, @publisher_db sysname) as
-- missing source code
go

create procedure sys.sp_MSdeletefoldercontents(@folder nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_MSdeletemetadataactionrequest(@pubid uniqueidentifier, @tablenick int,
                                                      @rowguid1 uniqueidentifier, @rowguid2 uniqueidentifier,
                                                      @rowguid3 uniqueidentifier, @rowguid4 uniqueidentifier,
                                                      @rowguid5 uniqueidentifier, @rowguid6 uniqueidentifier,
                                                      @rowguid7 uniqueidentifier, @rowguid8 uniqueidentifier,
                                                      @rowguid9 uniqueidentifier, @rowguid10 uniqueidentifier,
                                                      @rowguid11 uniqueidentifier, @rowguid12 uniqueidentifier,
                                                      @rowguid13 uniqueidentifier, @rowguid14 uniqueidentifier,
                                                      @rowguid15 uniqueidentifier, @rowguid16 uniqueidentifier,
                                                      @rowguid17 uniqueidentifier, @rowguid18 uniqueidentifier,
                                                      @rowguid19 uniqueidentifier, @rowguid20 uniqueidentifier,
                                                      @rowguid21 uniqueidentifier, @rowguid22 uniqueidentifier,
                                                      @rowguid23 uniqueidentifier, @rowguid24 uniqueidentifier,
                                                      @rowguid25 uniqueidentifier, @rowguid26 uniqueidentifier,
                                                      @rowguid27 uniqueidentifier, @rowguid28 uniqueidentifier,
                                                      @rowguid29 uniqueidentifier, @rowguid30 uniqueidentifier,
                                                      @rowguid31 uniqueidentifier, @rowguid32 uniqueidentifier,
                                                      @rowguid33 uniqueidentifier, @rowguid34 uniqueidentifier,
                                                      @rowguid35 uniqueidentifier, @rowguid36 uniqueidentifier,
                                                      @rowguid37 uniqueidentifier, @rowguid38 uniqueidentifier,
                                                      @rowguid39 uniqueidentifier, @rowguid40 uniqueidentifier,
                                                      @rowguid41 uniqueidentifier, @rowguid42 uniqueidentifier,
                                                      @rowguid43 uniqueidentifier, @rowguid44 uniqueidentifier,
                                                      @rowguid45 uniqueidentifier, @rowguid46 uniqueidentifier,
                                                      @rowguid47 uniqueidentifier, @rowguid48 uniqueidentifier,
                                                      @rowguid49 uniqueidentifier, @rowguid50 uniqueidentifier,
                                                      @rowguid51 uniqueidentifier, @rowguid52 uniqueidentifier,
                                                      @rowguid53 uniqueidentifier, @rowguid54 uniqueidentifier,
                                                      @rowguid55 uniqueidentifier, @rowguid56 uniqueidentifier,
                                                      @rowguid57 uniqueidentifier, @rowguid58 uniqueidentifier,
                                                      @rowguid59 uniqueidentifier, @rowguid60 uniqueidentifier,
                                                      @rowguid61 uniqueidentifier, @rowguid62 uniqueidentifier,
                                                      @rowguid63 uniqueidentifier, @rowguid64 uniqueidentifier,
                                                      @rowguid65 uniqueidentifier, @rowguid66 uniqueidentifier,
                                                      @rowguid67 uniqueidentifier, @rowguid68 uniqueidentifier,
                                                      @rowguid69 uniqueidentifier, @rowguid70 uniqueidentifier,
                                                      @rowguid71 uniqueidentifier, @rowguid72 uniqueidentifier,
                                                      @rowguid73 uniqueidentifier, @rowguid74 uniqueidentifier,
                                                      @rowguid75 uniqueidentifier, @rowguid76 uniqueidentifier,
                                                      @rowguid77 uniqueidentifier, @rowguid78 uniqueidentifier,
                                                      @rowguid79 uniqueidentifier, @rowguid80 uniqueidentifier,
                                                      @rowguid81 uniqueidentifier, @rowguid82 uniqueidentifier,
                                                      @rowguid83 uniqueidentifier, @rowguid84 uniqueidentifier,
                                                      @rowguid85 uniqueidentifier, @rowguid86 uniqueidentifier,
                                                      @rowguid87 uniqueidentifier, @rowguid88 uniqueidentifier,
                                                      @rowguid89 uniqueidentifier, @rowguid90 uniqueidentifier,
                                                      @rowguid91 uniqueidentifier, @rowguid92 uniqueidentifier,
                                                      @rowguid93 uniqueidentifier, @rowguid94 uniqueidentifier,
                                                      @rowguid95 uniqueidentifier, @rowguid96 uniqueidentifier,
                                                      @rowguid97 uniqueidentifier, @rowguid98 uniqueidentifier,
                                                      @rowguid99 uniqueidentifier, @rowguid100 uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSdeletepeerconflictrow(@originator_id nvarchar(32), @origin_datasource nvarchar(255),
                                                @tran_id nvarchar(40), @row_id nvarchar(19),
                                                @conflict_table nvarchar(270)) as
-- missing source code
go

create procedure sys.sp_MSdeleteretry(@temptable nvarchar(386), @tablenick int, @rowguid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSdeletetranconflictrow(@tran_id sysname, @row_id sysname, @conflict_table sysname) as
-- missing source code
go

create procedure sys.sp_MSdelgenzero() as
-- missing source code
go

create procedure sys.sp_MSdelrow(@rowguid uniqueidentifier, @tablenick int, @metadata_type tinyint,
                                 @lineage_old varbinary(311), @generation bigint, @lineage_new varbinary(311),
                                 @pubid uniqueidentifier, @check_permission int, @compatlevel int,
                                 @articleisupdateable bit, @publication_number smallint, @partition_id int) as
-- missing source code
go

create procedure sys.sp_MSdelrowsbatch(@pubid uniqueidentifier, @tablenick int, @check_permission int,
                                       @rows_tobe_deleted int, @partition_id int, @rowguid1 uniqueidentifier,
                                       @metadata_type1 tinyint, @generation1 bigint, @lineage_old1 varbinary(311),
                                       @lineage_new1 varbinary(311), @rowguid2 uniqueidentifier,
                                       @metadata_type2 tinyint, @generation2 bigint, @lineage_old2 varbinary(311),
                                       @lineage_new2 varbinary(311), @rowguid3 uniqueidentifier,
                                       @metadata_type3 tinyint, @generation3 bigint, @lineage_old3 varbinary(311),
                                       @lineage_new3 varbinary(311), @rowguid4 uniqueidentifier,
                                       @metadata_type4 tinyint, @generation4 bigint, @lineage_old4 varbinary(311),
                                       @lineage_new4 varbinary(311), @rowguid5 uniqueidentifier,
                                       @metadata_type5 tinyint, @generation5 bigint, @lineage_old5 varbinary(311),
                                       @lineage_new5 varbinary(311), @rowguid6 uniqueidentifier,
                                       @metadata_type6 tinyint, @generation6 bigint, @lineage_old6 varbinary(311),
                                       @lineage_new6 varbinary(311), @rowguid7 uniqueidentifier,
                                       @metadata_type7 tinyint, @generation7 bigint, @lineage_old7 varbinary(311),
                                       @lineage_new7 varbinary(311), @rowguid8 uniqueidentifier,
                                       @metadata_type8 tinyint, @generation8 bigint, @lineage_old8 varbinary(311),
                                       @lineage_new8 varbinary(311), @rowguid9 uniqueidentifier,
                                       @metadata_type9 tinyint, @generation9 bigint, @lineage_old9 varbinary(311),
                                       @lineage_new9 varbinary(311), @rowguid10 uniqueidentifier,
                                       @metadata_type10 tinyint, @generation10 bigint, @lineage_old10 varbinary(311),
                                       @lineage_new10 varbinary(311), @rowguid11 uniqueidentifier,
                                       @metadata_type11 tinyint, @generation11 bigint, @lineage_old11 varbinary(311),
                                       @lineage_new11 varbinary(311), @rowguid12 uniqueidentifier,
                                       @metadata_type12 tinyint, @generation12 bigint, @lineage_old12 varbinary(311),
                                       @lineage_new12 varbinary(311), @rowguid13 uniqueidentifier,
                                       @metadata_type13 tinyint, @generation13 bigint, @lineage_old13 varbinary(311),
                                       @lineage_new13 varbinary(311), @rowguid14 uniqueidentifier,
                                       @metadata_type14 tinyint, @generation14 bigint, @lineage_old14 varbinary(311),
                                       @lineage_new14 varbinary(311), @rowguid15 uniqueidentifier,
                                       @metadata_type15 tinyint, @generation15 bigint, @lineage_old15 varbinary(311),
                                       @lineage_new15 varbinary(311), @rowguid16 uniqueidentifier,
                                       @metadata_type16 tinyint, @generation16 bigint, @lineage_old16 varbinary(311),
                                       @lineage_new16 varbinary(311), @rowguid17 uniqueidentifier,
                                       @metadata_type17 tinyint, @generation17 bigint, @lineage_old17 varbinary(311),
                                       @lineage_new17 varbinary(311), @rowguid18 uniqueidentifier,
                                       @metadata_type18 tinyint, @generation18 bigint, @lineage_old18 varbinary(311),
                                       @lineage_new18 varbinary(311), @rowguid19 uniqueidentifier,
                                       @metadata_type19 tinyint, @generation19 bigint, @lineage_old19 varbinary(311),
                                       @lineage_new19 varbinary(311), @rowguid20 uniqueidentifier,
                                       @metadata_type20 tinyint, @generation20 bigint, @lineage_old20 varbinary(311),
                                       @lineage_new20 varbinary(311), @rowguid21 uniqueidentifier,
                                       @metadata_type21 tinyint, @generation21 bigint, @lineage_old21 varbinary(311),
                                       @lineage_new21 varbinary(311), @rowguid22 uniqueidentifier,
                                       @metadata_type22 tinyint, @generation22 bigint, @lineage_old22 varbinary(311),
                                       @lineage_new22 varbinary(311), @rowguid23 uniqueidentifier,
                                       @metadata_type23 tinyint, @generation23 bigint, @lineage_old23 varbinary(311),
                                       @lineage_new23 varbinary(311), @rowguid24 uniqueidentifier,
                                       @metadata_type24 tinyint, @generation24 bigint, @lineage_old24 varbinary(311),
                                       @lineage_new24 varbinary(311), @rowguid25 uniqueidentifier,
                                       @metadata_type25 tinyint, @generation25 bigint, @lineage_old25 varbinary(311),
                                       @lineage_new25 varbinary(311), @rowguid26 uniqueidentifier,
                                       @metadata_type26 tinyint, @generation26 bigint, @lineage_old26 varbinary(311),
                                       @lineage_new26 varbinary(311), @rowguid27 uniqueidentifier,
                                       @metadata_type27 tinyint, @generation27 bigint, @lineage_old27 varbinary(311),
                                       @lineage_new27 varbinary(311), @rowguid28 uniqueidentifier,
                                       @metadata_type28 tinyint, @generation28 bigint, @lineage_old28 varbinary(311),
                                       @lineage_new28 varbinary(311), @rowguid29 uniqueidentifier,
                                       @metadata_type29 tinyint, @generation29 bigint, @lineage_old29 varbinary(311),
                                       @lineage_new29 varbinary(311), @rowguid30 uniqueidentifier,
                                       @metadata_type30 tinyint, @generation30 bigint, @lineage_old30 varbinary(311),
                                       @lineage_new30 varbinary(311), @rowguid31 uniqueidentifier,
                                       @metadata_type31 tinyint, @generation31 bigint, @lineage_old31 varbinary(311),
                                       @lineage_new31 varbinary(311), @rowguid32 uniqueidentifier,
                                       @metadata_type32 tinyint, @generation32 bigint, @lineage_old32 varbinary(311),
                                       @lineage_new32 varbinary(311), @rowguid33 uniqueidentifier,
                                       @metadata_type33 tinyint, @generation33 bigint, @lineage_old33 varbinary(311),
                                       @lineage_new33 varbinary(311), @rowguid34 uniqueidentifier,
                                       @metadata_type34 tinyint, @generation34 bigint, @lineage_old34 varbinary(311),
                                       @lineage_new34 varbinary(311), @rowguid35 uniqueidentifier,
                                       @metadata_type35 tinyint, @generation35 bigint, @lineage_old35 varbinary(311),
                                       @lineage_new35 varbinary(311), @rowguid36 uniqueidentifier,
                                       @metadata_type36 tinyint, @generation36 bigint, @lineage_old36 varbinary(311),
                                       @lineage_new36 varbinary(311), @rowguid37 uniqueidentifier,
                                       @metadata_type37 tinyint, @generation37 bigint, @lineage_old37 varbinary(311),
                                       @lineage_new37 varbinary(311), @rowguid38 uniqueidentifier,
                                       @metadata_type38 tinyint, @generation38 bigint, @lineage_old38 varbinary(311),
                                       @lineage_new38 varbinary(311), @rowguid39 uniqueidentifier,
                                       @metadata_type39 tinyint, @generation39 bigint, @lineage_old39 varbinary(311),
                                       @lineage_new39 varbinary(311), @rowguid40 uniqueidentifier,
                                       @metadata_type40 tinyint, @generation40 bigint, @lineage_old40 varbinary(311),
                                       @lineage_new40 varbinary(311), @rowguid41 uniqueidentifier,
                                       @metadata_type41 tinyint, @generation41 bigint, @lineage_old41 varbinary(311),
                                       @lineage_new41 varbinary(311), @rowguid42 uniqueidentifier,
                                       @metadata_type42 tinyint, @generation42 bigint, @lineage_old42 varbinary(311),
                                       @lineage_new42 varbinary(311), @rowguid43 uniqueidentifier,
                                       @metadata_type43 tinyint, @generation43 bigint, @lineage_old43 varbinary(311),
                                       @lineage_new43 varbinary(311), @rowguid44 uniqueidentifier,
                                       @metadata_type44 tinyint, @generation44 bigint, @lineage_old44 varbinary(311),
                                       @lineage_new44 varbinary(311), @rowguid45 uniqueidentifier,
                                       @metadata_type45 tinyint, @generation45 bigint, @lineage_old45 varbinary(311),
                                       @lineage_new45 varbinary(311), @rowguid46 uniqueidentifier,
                                       @metadata_type46 tinyint, @generation46 bigint, @lineage_old46 varbinary(311),
                                       @lineage_new46 varbinary(311), @rowguid47 uniqueidentifier,
                                       @metadata_type47 tinyint, @generation47 bigint, @lineage_old47 varbinary(311),
                                       @lineage_new47 varbinary(311), @rowguid48 uniqueidentifier,
                                       @metadata_type48 tinyint, @generation48 bigint, @lineage_old48 varbinary(311),
                                       @lineage_new48 varbinary(311), @rowguid49 uniqueidentifier,
                                       @metadata_type49 tinyint, @generation49 bigint, @lineage_old49 varbinary(311),
                                       @lineage_new49 varbinary(311), @rowguid50 uniqueidentifier,
                                       @metadata_type50 tinyint, @generation50 bigint, @lineage_old50 varbinary(311),
                                       @lineage_new50 varbinary(311), @rowguid51 uniqueidentifier,
                                       @metadata_type51 tinyint, @generation51 bigint, @lineage_old51 varbinary(311),
                                       @lineage_new51 varbinary(311), @rowguid52 uniqueidentifier,
                                       @metadata_type52 tinyint, @generation52 bigint, @lineage_old52 varbinary(311),
                                       @lineage_new52 varbinary(311), @rowguid53 uniqueidentifier,
                                       @metadata_type53 tinyint, @generation53 bigint, @lineage_old53 varbinary(311),
                                       @lineage_new53 varbinary(311), @rowguid54 uniqueidentifier,
                                       @metadata_type54 tinyint, @generation54 bigint, @lineage_old54 varbinary(311),
                                       @lineage_new54 varbinary(311), @rowguid55 uniqueidentifier,
                                       @metadata_type55 tinyint, @generation55 bigint, @lineage_old55 varbinary(311),
                                       @lineage_new55 varbinary(311), @rowguid56 uniqueidentifier,
                                       @metadata_type56 tinyint, @generation56 bigint, @lineage_old56 varbinary(311),
                                       @lineage_new56 varbinary(311), @rowguid57 uniqueidentifier,
                                       @metadata_type57 tinyint, @generation57 bigint, @lineage_old57 varbinary(311),
                                       @lineage_new57 varbinary(311), @rowguid58 uniqueidentifier,
                                       @metadata_type58 tinyint, @generation58 bigint, @lineage_old58 varbinary(311),
                                       @lineage_new58 varbinary(311), @rowguid59 uniqueidentifier,
                                       @metadata_type59 tinyint, @generation59 bigint, @lineage_old59 varbinary(311),
                                       @lineage_new59 varbinary(311), @rowguid60 uniqueidentifier,
                                       @metadata_type60 tinyint, @generation60 bigint, @lineage_old60 varbinary(311),
                                       @lineage_new60 varbinary(311), @rowguid61 uniqueidentifier,
                                       @metadata_type61 tinyint, @generation61 bigint, @lineage_old61 varbinary(311),
                                       @lineage_new61 varbinary(311), @rowguid62 uniqueidentifier,
                                       @metadata_type62 tinyint, @generation62 bigint, @lineage_old62 varbinary(311),
                                       @lineage_new62 varbinary(311), @rowguid63 uniqueidentifier,
                                       @metadata_type63 tinyint, @generation63 bigint, @lineage_old63 varbinary(311),
                                       @lineage_new63 varbinary(311), @rowguid64 uniqueidentifier,
                                       @metadata_type64 tinyint, @generation64 bigint, @lineage_old64 varbinary(311),
                                       @lineage_new64 varbinary(311), @rowguid65 uniqueidentifier,
                                       @metadata_type65 tinyint, @generation65 bigint, @lineage_old65 varbinary(311),
                                       @lineage_new65 varbinary(311), @rowguid66 uniqueidentifier,
                                       @metadata_type66 tinyint, @generation66 bigint, @lineage_old66 varbinary(311),
                                       @lineage_new66 varbinary(311), @rowguid67 uniqueidentifier,
                                       @metadata_type67 tinyint, @generation67 bigint, @lineage_old67 varbinary(311),
                                       @lineage_new67 varbinary(311), @rowguid68 uniqueidentifier,
                                       @metadata_type68 tinyint, @generation68 bigint, @lineage_old68 varbinary(311),
                                       @lineage_new68 varbinary(311), @rowguid69 uniqueidentifier,
                                       @metadata_type69 tinyint, @generation69 bigint, @lineage_old69 varbinary(311),
                                       @lineage_new69 varbinary(311), @rowguid70 uniqueidentifier,
                                       @metadata_type70 tinyint, @generation70 bigint, @lineage_old70 varbinary(311),
                                       @lineage_new70 varbinary(311), @rowguid71 uniqueidentifier,
                                       @metadata_type71 tinyint, @generation71 bigint, @lineage_old71 varbinary(311),
                                       @lineage_new71 varbinary(311), @rowguid72 uniqueidentifier,
                                       @metadata_type72 tinyint, @generation72 bigint, @lineage_old72 varbinary(311),
                                       @lineage_new72 varbinary(311), @rowguid73 uniqueidentifier,
                                       @metadata_type73 tinyint, @generation73 bigint, @lineage_old73 varbinary(311),
                                       @lineage_new73 varbinary(311), @rowguid74 uniqueidentifier,
                                       @metadata_type74 tinyint, @generation74 bigint, @lineage_old74 varbinary(311),
                                       @lineage_new74 varbinary(311), @rowguid75 uniqueidentifier,
                                       @metadata_type75 tinyint, @generation75 bigint, @lineage_old75 varbinary(311),
                                       @lineage_new75 varbinary(311), @rowguid76 uniqueidentifier,
                                       @metadata_type76 tinyint, @generation76 bigint, @lineage_old76 varbinary(311),
                                       @lineage_new76 varbinary(311), @rowguid77 uniqueidentifier,
                                       @metadata_type77 tinyint, @generation77 bigint, @lineage_old77 varbinary(311),
                                       @lineage_new77 varbinary(311), @rowguid78 uniqueidentifier,
                                       @metadata_type78 tinyint, @generation78 bigint, @lineage_old78 varbinary(311),
                                       @lineage_new78 varbinary(311), @rowguid79 uniqueidentifier,
                                       @metadata_type79 tinyint, @generation79 bigint, @lineage_old79 varbinary(311),
                                       @lineage_new79 varbinary(311), @rowguid80 uniqueidentifier,
                                       @metadata_type80 tinyint, @generation80 bigint, @lineage_old80 varbinary(311),
                                       @lineage_new80 varbinary(311), @rowguid81 uniqueidentifier,
                                       @metadata_type81 tinyint, @generation81 bigint, @lineage_old81 varbinary(311),
                                       @lineage_new81 varbinary(311), @rowguid82 uniqueidentifier,
                                       @metadata_type82 tinyint, @generation82 bigint, @lineage_old82 varbinary(311),
                                       @lineage_new82 varbinary(311), @rowguid83 uniqueidentifier,
                                       @metadata_type83 tinyint, @generation83 bigint, @lineage_old83 varbinary(311),
                                       @lineage_new83 varbinary(311), @rowguid84 uniqueidentifier,
                                       @metadata_type84 tinyint, @generation84 bigint, @lineage_old84 varbinary(311),
                                       @lineage_new84 varbinary(311), @rowguid85 uniqueidentifier,
                                       @metadata_type85 tinyint, @generation85 bigint, @lineage_old85 varbinary(311),
                                       @lineage_new85 varbinary(311), @rowguid86 uniqueidentifier,
                                       @metadata_type86 tinyint, @generation86 bigint, @lineage_old86 varbinary(311),
                                       @lineage_new86 varbinary(311), @rowguid87 uniqueidentifier,
                                       @metadata_type87 tinyint, @generation87 bigint, @lineage_old87 varbinary(311),
                                       @lineage_new87 varbinary(311), @rowguid88 uniqueidentifier,
                                       @metadata_type88 tinyint, @generation88 bigint, @lineage_old88 varbinary(311),
                                       @lineage_new88 varbinary(311), @rowguid89 uniqueidentifier,
                                       @metadata_type89 tinyint, @generation89 bigint, @lineage_old89 varbinary(311),
                                       @lineage_new89 varbinary(311), @rowguid90 uniqueidentifier,
                                       @metadata_type90 tinyint, @generation90 bigint, @lineage_old90 varbinary(311),
                                       @lineage_new90 varbinary(311), @rowguid91 uniqueidentifier,
                                       @metadata_type91 tinyint, @generation91 bigint, @lineage_old91 varbinary(311),
                                       @lineage_new91 varbinary(311), @rowguid92 uniqueidentifier,
                                       @metadata_type92 tinyint, @generation92 bigint, @lineage_old92 varbinary(311),
                                       @lineage_new92 varbinary(311), @rowguid93 uniqueidentifier,
                                       @metadata_type93 tinyint, @generation93 bigint, @lineage_old93 varbinary(311),
                                       @lineage_new93 varbinary(311), @rowguid94 uniqueidentifier,
                                       @metadata_type94 tinyint, @generation94 bigint, @lineage_old94 varbinary(311),
                                       @lineage_new94 varbinary(311), @rowguid95 uniqueidentifier,
                                       @metadata_type95 tinyint, @generation95 bigint, @lineage_old95 varbinary(311),
                                       @lineage_new95 varbinary(311), @rowguid96 uniqueidentifier,
                                       @metadata_type96 tinyint, @generation96 bigint, @lineage_old96 varbinary(311),
                                       @lineage_new96 varbinary(311), @rowguid97 uniqueidentifier,
                                       @metadata_type97 tinyint, @generation97 bigint, @lineage_old97 varbinary(311),
                                       @lineage_new97 varbinary(311), @rowguid98 uniqueidentifier,
                                       @metadata_type98 tinyint, @generation98 bigint, @lineage_old98 varbinary(311),
                                       @lineage_new98 varbinary(311), @rowguid99 uniqueidentifier,
                                       @metadata_type99 tinyint, @generation99 bigint, @lineage_old99 varbinary(311),
                                       @lineage_new99 varbinary(311), @rowguid100 uniqueidentifier,
                                       @metadata_type100 tinyint, @generation100 bigint, @lineage_old100 varbinary(311),
                                       @lineage_new100 varbinary(311)) as
-- missing source code
go

create procedure sys.sp_MSdelrowsbatch_downloadonly(@pubid uniqueidentifier, @tablenick int, @check_permission int,
                                                    @rows_tobe_deleted int, @rowguid1 uniqueidentifier,
                                                    @rowguid2 uniqueidentifier, @rowguid3 uniqueidentifier,
                                                    @rowguid4 uniqueidentifier, @rowguid5 uniqueidentifier,
                                                    @rowguid6 uniqueidentifier, @rowguid7 uniqueidentifier,
                                                    @rowguid8 uniqueidentifier, @rowguid9 uniqueidentifier,
                                                    @rowguid10 uniqueidentifier, @rowguid11 uniqueidentifier,
                                                    @rowguid12 uniqueidentifier, @rowguid13 uniqueidentifier,
                                                    @rowguid14 uniqueidentifier, @rowguid15 uniqueidentifier,
                                                    @rowguid16 uniqueidentifier, @rowguid17 uniqueidentifier,
                                                    @rowguid18 uniqueidentifier, @rowguid19 uniqueidentifier,
                                                    @rowguid20 uniqueidentifier, @rowguid21 uniqueidentifier,
                                                    @rowguid22 uniqueidentifier, @rowguid23 uniqueidentifier,
                                                    @rowguid24 uniqueidentifier, @rowguid25 uniqueidentifier,
                                                    @rowguid26 uniqueidentifier, @rowguid27 uniqueidentifier,
                                                    @rowguid28 uniqueidentifier, @rowguid29 uniqueidentifier,
                                                    @rowguid30 uniqueidentifier, @rowguid31 uniqueidentifier,
                                                    @rowguid32 uniqueidentifier, @rowguid33 uniqueidentifier,
                                                    @rowguid34 uniqueidentifier, @rowguid35 uniqueidentifier,
                                                    @rowguid36 uniqueidentifier, @rowguid37 uniqueidentifier,
                                                    @rowguid38 uniqueidentifier, @rowguid39 uniqueidentifier,
                                                    @rowguid40 uniqueidentifier, @rowguid41 uniqueidentifier,
                                                    @rowguid42 uniqueidentifier, @rowguid43 uniqueidentifier,
                                                    @rowguid44 uniqueidentifier, @rowguid45 uniqueidentifier,
                                                    @rowguid46 uniqueidentifier, @rowguid47 uniqueidentifier,
                                                    @rowguid48 uniqueidentifier, @rowguid49 uniqueidentifier,
                                                    @rowguid50 uniqueidentifier, @rowguid51 uniqueidentifier,
                                                    @rowguid52 uniqueidentifier, @rowguid53 uniqueidentifier,
                                                    @rowguid54 uniqueidentifier, @rowguid55 uniqueidentifier,
                                                    @rowguid56 uniqueidentifier, @rowguid57 uniqueidentifier,
                                                    @rowguid58 uniqueidentifier, @rowguid59 uniqueidentifier,
                                                    @rowguid60 uniqueidentifier, @rowguid61 uniqueidentifier,
                                                    @rowguid62 uniqueidentifier, @rowguid63 uniqueidentifier,
                                                    @rowguid64 uniqueidentifier, @rowguid65 uniqueidentifier,
                                                    @rowguid66 uniqueidentifier, @rowguid67 uniqueidentifier,
                                                    @rowguid68 uniqueidentifier, @rowguid69 uniqueidentifier,
                                                    @rowguid70 uniqueidentifier, @rowguid71 uniqueidentifier,
                                                    @rowguid72 uniqueidentifier, @rowguid73 uniqueidentifier,
                                                    @rowguid74 uniqueidentifier, @rowguid75 uniqueidentifier,
                                                    @rowguid76 uniqueidentifier, @rowguid77 uniqueidentifier,
                                                    @rowguid78 uniqueidentifier, @rowguid79 uniqueidentifier,
                                                    @rowguid80 uniqueidentifier, @rowguid81 uniqueidentifier,
                                                    @rowguid82 uniqueidentifier, @rowguid83 uniqueidentifier,
                                                    @rowguid84 uniqueidentifier, @rowguid85 uniqueidentifier,
                                                    @rowguid86 uniqueidentifier, @rowguid87 uniqueidentifier,
                                                    @rowguid88 uniqueidentifier, @rowguid89 uniqueidentifier,
                                                    @rowguid90 uniqueidentifier, @rowguid91 uniqueidentifier,
                                                    @rowguid92 uniqueidentifier, @rowguid93 uniqueidentifier,
                                                    @rowguid94 uniqueidentifier, @rowguid95 uniqueidentifier,
                                                    @rowguid96 uniqueidentifier, @rowguid97 uniqueidentifier,
                                                    @rowguid98 uniqueidentifier, @rowguid99 uniqueidentifier,
                                                    @rowguid100 uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSdelsubrows(@rowguid uniqueidentifier, @tablenick int, @metadata_type tinyint,
                                     @lineage_old varbinary(311), @generation bigint, @lineage_new varbinary(311),
                                     @pubid uniqueidentifier, @rowsdeleted int, @compatlevel int,
                                     @allarticlesareupdateable bit) as
-- missing source code
go

create procedure sys.sp_MSdelsubrowsbatch(@tablenick int, @rowguid_array varbinary(8000),
                                          @metadatatype_array varbinary(500), @oldlineage_len_array varbinary(1000),
                                          @oldlineage_array varbinary(311), @generation_array varbinary(4000),
                                          @newlineage_len_array varbinary(1000), @newlineage_array varbinary(311),
                                          @pubid uniqueidentifier, @rowsdeleted int, @allarticlesareupdateable bit) as
-- missing source code
go

create procedure sys.sp_MSdependencies(@objname nvarchar(517), @objtype int, @flags int, @objlist nvarchar(128),
                                       @intrans int) as
-- missing source code
go

create procedure sys.sp_MSdetect_nonlogged_shutdown(@subsystem nvarchar(60), @agent_id int) as
-- missing source code
go

create procedure sys.sp_MSdetectinvalidpeerconfiguration(@publisher sysname, @publisher_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_MSdetectinvalidpeersubscription(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                        @dest_table sysname, @dest_owner sysname, @article sysname,
                                                        @type sysname) as
-- missing source code
go

create procedure sys.sp_MSdist_activate_auto_sub(@publisher_id int, @publisher_db sysname, @article_id int) as
-- missing source code
go

create procedure sys.sp_MSdist_adjust_identity(@agent_id int, @tablename sysname) as
-- missing source code
go

create procedure sys.sp_MSdistpublisher_cleanup(@publisher sysname) as
-- missing source code
go

create procedure sys.sp_MSdistribution_counters(@publisher sysname) as
-- missing source code
go

create procedure sys.sp_MSdistributoravailable() as
-- missing source code
go

create procedure sys.sp_MSdodatabasesnapshotinitiation(@publication sysname) as
-- missing source code
go

create procedure sys.sp_MSdopartialdatabasesnapshotinitiation(@publication sysname) as
-- missing source code
go

create procedure sys.sp_MSdrop_6x_publication(@job_id uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSdrop_6x_replication_agent(@job_id uniqueidentifier, @category_id int) as
-- missing source code
go

create procedure sys.sp_MSdrop_anonymous_entry(@subid uniqueidentifier, @login sysname, @type int) as
-- missing source code
go

create procedure sys.sp_MSdrop_article(@publisher sysname, @publisher_db sysname, @publication sysname,
                                       @article sysname) as
-- missing source code
go

create procedure sys.sp_MSdrop_distribution_agent(@publisher_id smallint, @publisher_db sysname, @publication sysname,
                                                  @subscriber_id smallint, @subscriber_db sysname,
                                                  @subscription_type int, @keep_for_last_run bit, @job_only bit) as
-- missing source code
go

create procedure sys.sp_MSdrop_distribution_agentid_dbowner_proxy(@agent_id int) as
-- missing source code
go

create procedure sys.sp_MSdrop_dynamic_snapshot_agent(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                      @agent_id int) as
-- missing source code
go

create procedure sys.sp_MSdrop_logreader_agent(@publisher sysname, @publisher_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_MSdrop_merge_agent(@publisher sysname, @publisher_db sysname, @publication sysname,
                                           @subscriber sysname, @subscriber_db sysname, @keep_for_last_run bit,
                                           @job_only bit) as
-- missing source code
go

create procedure sys.sp_MSdrop_merge_subscription(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                  @subscriber sysname, @subscriber_db sysname,
                                                  @subscription_type nvarchar(15)) as
-- missing source code
go

create procedure sys.sp_MSdrop_publication(@publisher sysname, @publisher_db sysname, @publication sysname,
                                           @alt_snapshot_folder sysname, @cleanup_orphans bit) as
-- missing source code
go

create procedure sys.sp_MSdrop_qreader_history(@publication_id int) as
-- missing source code
go

create procedure sys.sp_MSdrop_snapshot_agent(@publisher sysname, @publisher_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_MSdrop_snapshot_dirs() as
-- missing source code
go

create procedure sys.sp_MSdrop_subscriber_info(@publisher sysname, @subscriber sysname) as
-- missing source code
go

create procedure sys.sp_MSdrop_subscription(@publisher sysname, @publisher_db sysname, @subscriber sysname,
                                            @article_id int, @subscriber_db sysname, @publication sysname,
                                            @article sysname) as
-- missing source code
go

create procedure sys.sp_MSdrop_subscription_3rd(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                @subscriber sysname, @subscriber_db sysname) as
-- missing source code
go

create procedure sys.sp_MSdrop_tempgenhistorytable(@pubid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSdroparticleconstraints(@destination_object sysname, @destination_owner sysname) as
-- missing source code
go

create procedure sys.sp_MSdroparticletombstones(@artid uniqueidentifier, @pubid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSdropconstraints(@table sysname, @owner sysname) as
-- missing source code
go

create procedure sys.sp_MSdropdynsnapshotvws(@dynamic_snapshot_views_table sysname) as
-- missing source code
go

create procedure sys.sp_MSdropfkreferencingarticle(@destination_object_name sysname, @destination_owner_name sysname) as
-- missing source code
go

create procedure sys.sp_MSdropmergearticle(@pubid uniqueidentifier, @artid uniqueidentifier,
                                           @ignore_merge_metadata bit) as
-- missing source code
go

create procedure sys.sp_MSdropmergedynamicsnapshotjob(@publication sysname, @dynamic_snapshot_jobname sysname,
                                                      @dynamic_snapshot_jobid uniqueidentifier,
                                                      @ignore_distributor bit) as
-- missing source code
go

create procedure sys.sp_MSdropobsoletearticle(@artid int, @ignore_distributor bit, @force_invalidate_snapshot bit) as
-- missing source code
go

create procedure sys.sp_MSdropretry(@tname sysname, @pname sysname) as
-- missing source code
go

create procedure sys.sp_MSdroptemptable(@tname sysname) as
-- missing source code
go

create procedure sys.sp_MSdummyupdate(@rowguid uniqueidentifier, @tablenick int, @metatype tinyint,
                                      @pubid uniqueidentifier, @uplineage tinyint, @inlineage varbinary(311),
                                      @incolv varbinary(2953)) as
-- missing source code
go

create procedure sys.sp_MSdummyupdate90(@rowguid uniqueidentifier, @tablenick int, @metatype tinyint,
                                        @pubid uniqueidentifier, @inlineage varbinary(311), @incolv varbinary(2953),
                                        @logical_record_parent_rowguid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSdummyupdate_logicalrecord(@parent_rowguid uniqueidentifier, @parent_nickname int,
                                                    @dest_common_gen bigint) as
-- missing source code
go

create procedure sys.sp_MSdummyupdatelightweight(@tablenick int, @rowguid uniqueidentifier, @action int,
                                                 @metatype tinyint, @rowvector varbinary(11)) as
-- missing source code
go

create procedure sys.sp_MSdynamicsnapshotjobexistsatdistributor(@publisher sysname, @publisher_db sysname,
                                                                @publication sysname, @dynamic_filter_login sysname,
                                                                @dynamic_filter_hostname sysname,
                                                                @dynamic_snapshot_jobid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSenable_publication_for_het_sub(@publisher sysname, @publisher_db sysname,
                                                         @publication sysname, @sync_method int) as
-- missing source code
go

create procedure sys.sp_MSensure_single_instance(@application_name sysname, @agent_type int) as
-- missing source code
go

create procedure sys.sp_MSenum_distribution(@name nvarchar(100), @show_distdb bit, @exclude_anonymous bit) as
-- missing source code
go

create procedure sys.sp_MSenum_distribution_s(@name nvarchar(100), @hours int, @session_type int) as
-- missing source code
go

create procedure sys.sp_MSenum_distribution_sd(@name nvarchar(100), @time datetime) as
-- missing source code
go

create procedure sys.sp_MSenum_logicalrecord_changes(@partition_id int, @genlist varchar(8000), @parent_nickname int,
                                                     @pubid uniqueidentifier, @oldmaxgen bigint, @mingen bigint,
                                                     @maxgen bigint, @enumentirerowmetadata bit,
                                                     @maxschemaguidforarticle uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSenum_logreader(@name nvarchar(100), @show_distdb bit) as
-- missing source code
go

create procedure sys.sp_MSenum_logreader_s(@name nvarchar(100), @hours int, @session_type int) as
-- missing source code
go

create procedure sys.sp_MSenum_logreader_sd(@name nvarchar(100), @time datetime) as
-- missing source code
go

create procedure sys.sp_MSenum_merge(@name nvarchar(100), @show_distdb bit, @exclude_anonymous bit) as
-- missing source code
go

create procedure sys.sp_MSenum_merge_agent_properties(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                      @show_security bit) as
-- missing source code
go

create procedure sys.sp_MSenum_merge_s(@name nvarchar(100), @hours int, @session_type int) as
-- missing source code
go

create procedure sys.sp_MSenum_merge_sd(@name nvarchar(100), @time datetime) as
-- missing source code
go

create procedure sys.sp_MSenum_merge_subscriptions(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                   @exclude_anonymous bit) as
-- missing source code
go

create procedure sys.sp_MSenum_merge_subscriptions_90_publication(@publisher sysname, @publisher_db sysname,
                                                                  @publication sysname, @topNum int,
                                                                  @exclude_anonymous bit) as
-- missing source code
go

create procedure sys.sp_MSenum_merge_subscriptions_90_publisher(@publisher sysname, @topNum int, @exclude_anonymous bit) as
-- missing source code
go

create procedure sys.sp_MSenum_metadataaction_requests(@tablenick_last int, @rowguid_last uniqueidentifier,
                                                       @pubid uniqueidentifier, @max_rows int) as
-- missing source code
go

create procedure sys.sp_MSenum_qreader(@name nvarchar(100), @show_distdb bit) as
-- missing source code
go

create procedure sys.sp_MSenum_qreader_s(@publication_id int, @hours int, @session_type int) as
-- missing source code
go

create procedure sys.sp_MSenum_qreader_sd(@publication_id int, @time datetime) as
-- missing source code
go

create procedure sys.sp_MSenum_replication_agents(@type int, @exclude_anonymous bit, @check_user bit) as
-- missing source code
go

create procedure sys.sp_MSenum_replication_job(@job_id uniqueidentifier, @step_uid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSenum_replqueues(@curdistdb sysname) as
-- missing source code
go

create procedure sys.sp_MSenum_replsqlqueues(@curdistdb sysname) as
-- missing source code
go

create procedure sys.sp_MSenum_snapshot(@name nvarchar(100), @show_distdb bit) as
-- missing source code
go

create procedure sys.sp_MSenum_snapshot_s(@name nvarchar(100), @hours int, @session_type int) as
-- missing source code
go

create procedure sys.sp_MSenum_snapshot_sd(@name nvarchar(100), @time datetime) as
-- missing source code
go

create procedure sys.sp_MSenum_subscriptions(@publisher sysname, @publisher_db sysname, @publication sysname,
                                             @exclude_anonymous bit) as
-- missing source code
go

create procedure sys.sp_MSenumallpublications(@publisherdb sysname, @replication_type tinyint, @agent_login sysname,
                                              @security_check bit, @vendor_name sysname, @publication sysname,
                                              @hrepl_pub bit, @empty_tranpub bit) as
-- missing source code
go

create procedure sys.sp_MSenumallsubscriptions(@subscription_type nvarchar(5), @subscriber_db sysname) as
-- missing source code
go

create procedure sys.sp_MSenumarticleslightweight(@pubid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSenumchanges(@maxrows int, @genlist varchar(8000), @tablenick int, @rowguid uniqueidentifier,
                                      @pubid uniqueidentifier, @oldmaxgen bigint, @mingen bigint, @maxgen bigint,
                                      @compatlevel int, @return_count_of_rows_initially_enumerated bit,
                                      @enumentirerowmetadata bit, @blob_cols_at_the_end bit,
                                      @maxschemaguidforarticle uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSenumchanges_belongtopartition(@partition_id int, @maxrows int, @genlist varchar(8000),
                                                        @tablenick int, @rowguid uniqueidentifier,
                                                        @pubid uniqueidentifier, @mingen bigint, @maxgen bigint,
                                                        @enumentirerowmetadata bit, @blob_cols_at_the_end bit,
                                                        @maxschemaguidforarticle uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSenumchanges_notbelongtopartition(@partition_id int, @maxrows int, @genlist varchar(8000),
                                                           @tablenick int, @rowguid uniqueidentifier,
                                                           @pubid uniqueidentifier, @mingen bigint, @maxgen bigint,
                                                           @enumentirerowmetadata bit) as
-- missing source code
go

create procedure sys.sp_MSenumchangesdirect(@maxrows int, @genlist varchar(2000), @tablenick int,
                                            @rowguid uniqueidentifier, @pubid uniqueidentifier, @oldmaxgen bigint,
                                            @mingen bigint, @maxgen bigint, @compatlevel int,
                                            @enumentirerowmetadata bit, @blob_cols_at_the_end bit,
                                            @maxschemaguidforarticle uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSenumchangeslightweight(@pubid uniqueidentifier, @tablenick int, @lastrowguid uniqueidentifier,
                                                 @maxrows int) as
-- missing source code
go

create procedure sys.sp_MSenumcolumns(@pubid uniqueidentifier, @artid uniqueidentifier,
                                      @maxschemaguidforarticle uniqueidentifier, @show_filtering_columns bit) as
-- missing source code
go

create procedure sys.sp_MSenumcolumnslightweight(@pubid uniqueidentifier, @artid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSenumdeletes_forpartition(@partition_id int, @maxrows int, @genlist varchar(8000),
                                                   @tablenick int, @rowguid uniqueidentifier, @pubid uniqueidentifier,
                                                   @mingen bigint, @maxgen bigint, @enumentirerowmetadata bit) as
-- missing source code
go

create procedure sys.sp_MSenumdeleteslightweight(@pubid uniqueidentifier, @tablenick int, @lastrowguid uniqueidentifier,
                                                 @maxrows int) as
-- missing source code
go

create procedure sys.sp_MSenumdeletesmetadata(@pubid uniqueidentifier, @maxrows int, @genlist varchar(8000),
                                              @tablenick int, @rowguid uniqueidentifier, @filter_partialdeletes int,
                                              @specified_article_only int, @mingen bigint, @maxgen bigint,
                                              @compatlevel int, @enumentirerowmetadata bit) as
-- missing source code
go

create procedure sys.sp_MSenumdistributionagentproperties(@publisher sysname, @publisher_db sysname,
                                                          @publication sysname, @show_security bit) as
-- missing source code
go

create procedure sys.sp_MSenumerate_PAL(@publisher sysname, @publisher_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_MSenumgenerations(@genstart bigint, @pubid uniqueidentifier,
                                          @return_count_of_generations bit) as
-- missing source code
go

create procedure sys.sp_MSenumgenerations90(@genstart bigint, @pubid uniqueidentifier, @partition_id int, @numgens int,
                                            @mingen_to_enumerate bigint, @maxgen_to_enumerate bigint) as
-- missing source code
go

create procedure sys.sp_MSenumpartialchanges(@maxrows int, @temp_cont sysname, @tablenick int,
                                             @rowguid uniqueidentifier, @pubid uniqueidentifier, @compatlevel int,
                                             @return_count_of_rows_initially_enumerated bit, @enumentirerowmetadata bit,
                                             @blob_cols_at_the_end bit, @maxschemaguidforarticle uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSenumpartialchangesdirect(@maxrows int, @temp_cont sysname, @tablenick int,
                                                   @rowguid uniqueidentifier, @pubid uniqueidentifier, @compatlevel int,
                                                   @enumentirerowmetadata bit, @blob_cols_at_the_end bit,
                                                   @maxschemaguidforarticle uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSenumpartialdeletes(@maxrows int, @tablenick int, @rowguid uniqueidentifier,
                                             @tablenotbelongs nvarchar(255), @bookmark int, @specified_article_only int,
                                             @compatlevel int, @pubid uniqueidentifier, @enumentirerowmetadata bit) as
-- missing source code
go

create procedure sys.sp_MSenumpubreferences(@publication sysname) as
-- missing source code
go

create procedure sys.sp_MSenumreplicas(@pubid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSenumreplicas90() as
-- missing source code
go

create procedure sys.sp_MSenumretries(@tname nvarchar(126), @maxrows int, @tablenick int, @rowguid uniqueidentifier,
                                      @pubid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSenumschemachange(@pubid uniqueidentifier, @schemaversion int, @compatlevel int,
                                           @AlterTableOnly bit, @invalidateupload_schemachanges_for_ssce bit,
                                           @filter_skipped_schemachanges bit) as
-- missing source code
go

create procedure sys.sp_MSenumsubscriptions(@subscription_type nvarchar(5), @publisher sysname, @publisher_db sysname,
                                            @reserved bit) as
-- missing source code
go

create procedure sys.sp_MSenumthirdpartypublicationvendornames(@within_db bit) as
-- missing source code
go

create procedure sys.sp_MSestimatemergesnapshotworkload(@publication sysname) as
-- missing source code
go

create procedure sys.sp_MSestimatesnapshotworkload(@publication sysname) as
-- missing source code
go

create procedure sys.sp_MSevalsubscriberinfo(@pubid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSevaluate_change_membership_for_all_articles_in_pubid(@pubid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSevaluate_change_membership_for_pubid(@pubid uniqueidentifier, @partition_id int) as
-- missing source code
go

create procedure sys.sp_MSevaluate_change_membership_for_row(@tablenick int, @rowguid uniqueidentifier, @marker uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSexecwithlsnoutput(@command nvarchar(max), @xact_seqno varbinary(16)) as
-- missing source code
go

create procedure sys.sp_MSfast_delete_trans() as
-- missing source code
go

create procedure sys.sp_MSfetchAdjustidentityrange(@publisher sysname, @publisher_db sysname, @tablename sysname,
                                                   @adjust_only bit, @for_publisher tinyint, @range bigint,
                                                   @next_seed bigint, @threshold int) as
-- missing source code
go

create procedure sys.sp_MSfetchidentityrange(@tablename nvarchar(270), @adjust_only bit, @table_owner sysname) as
-- missing source code
go

create procedure sys.sp_MSfillupmissingcols(@publication sysname, @source_table sysname) as
-- missing source code
go

create procedure sys.sp_MSfilterclause(@publication nvarchar(258), @article nvarchar(258)) as
-- missing source code
go

create procedure sys.sp_MSfix_6x_tasks(@publisher sysname, @publisher_engine_edition int) as
-- missing source code
go

create procedure sys.sp_MSfixlineageversions() as
-- missing source code
go

create procedure sys.sp_MSfixupbeforeimagetables(@pubid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSflush_access_cache() as
-- missing source code
go

create procedure sys.sp_MSforce_drop_distribution_jobs(@publisher sysname, @publisher_db sysname, @type nvarchar(5)) as
-- missing source code
go

create procedure sys.sp_MSforcereenumeration(@tablenick int, @rowguid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSforeach_worker(@command1 nvarchar(2000), @replacechar nchar, @command2 nvarchar(2000),
                                         @command3 nvarchar(2000), @worker_type int) as
-- missing source code
go

create procedure sys.sp_MSforeachdb(@command1 nvarchar(2000), @replacechar nchar, @command2 nvarchar(2000),
                                    @command3 nvarchar(2000), @precommand nvarchar(2000),
                                    @postcommand nvarchar(2000)) as
-- missing source code
go

create procedure sys.sp_MSforeachtable(@command1 nvarchar(2000), @replacechar nchar, @command2 nvarchar(2000),
                                       @command3 nvarchar(2000), @whereand nvarchar(2000), @precommand nvarchar(2000),
                                       @postcommand nvarchar(2000)) as
-- missing source code
go

create procedure sys.sp_MSgenerateexpandproc(@tablenick int, @procname sysname) as
-- missing source code
go

create procedure sys.sp_MSget_DDL_after_regular_snapshot(@publication sysname, @ddl_present bit) as
-- missing source code
go

create procedure sys.sp_MSget_MSmerge_rowtrack_colinfo() as
-- missing source code
go

create procedure sys.sp_MSget_agent_names(@publication sysname, @subscriber sysname, @subscriber_db sysname,
                                          @publisher sysname, @publisher_db sysname) as
-- missing source code
go

create procedure sys.sp_MSget_attach_state(@publisher sysname, @publisher_db sysname, @publication sysname,
                                           @subscription_type int) as
-- missing source code
go

create procedure sys.sp_MSget_dynamic_snapshot_location(@pubid uniqueidentifier, @partition_id int,
                                                        @dynsnap_location nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_MSget_identity_range_info(@subid uniqueidentifier, @artid uniqueidentifier, @range_type tinyint,
                                                  @ranges_needed tinyint, @range_begin numeric(38),
                                                  @range_end numeric(38), @next_range_begin numeric(38),
                                                  @next_range_end numeric(38)) as
-- missing source code
go

create procedure sys.sp_MSget_jobstate(@job_id uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSget_last_transaction(@publisher_id int, @publisher_db sysname, @publisher sysname,
                                               @max_xact_seqno varbinary(16), @for_truncate bit) as
-- missing source code
go

create procedure sys.sp_MSget_latest_peerlsn(@originator_publication sysname, @originator sysname,
                                             @originator_db sysname, @xact_seqno binary(10)) as
-- missing source code
go

create procedure sys.sp_MSget_load_hint(@qualified_source_object_name nvarchar(4000),
                                        @qualified_sync_object_name nvarchar(4000), @primary_key_only bit,
                                        @is_vertically_partitioned bit) as
-- missing source code
go

create procedure sys.sp_MSget_log_shipping_new_sessionid(@agent_id uniqueidentifier, @agent_type tinyint, @session_id int) as
-- missing source code
go

create procedure sys.sp_MSget_logicalrecord_lineage(@pubid uniqueidentifier, @parent_nickname int,
                                                    @parent_rowguid uniqueidentifier, @dest_common_gen bigint) as
-- missing source code
go

create procedure sys.sp_MSget_max_used_identity(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                @article sysname, @max_used numeric(38)) as
-- missing source code
go

create procedure sys.sp_MSget_min_seqno(@agent_id int, @xact_seqno varbinary(16)) as
-- missing source code
go

create procedure sys.sp_MSget_new_xact_seqno(@publisher_id int, @publisher_db sysname, @len tinyint) as
-- missing source code
go

create procedure sys.sp_MSget_oledbinfo(@server nvarchar(128), @infotype nvarchar(128), @login nvarchar(128),
                                        @password nvarchar(128)) as
-- missing source code
go

create procedure sys.sp_MSget_partitionid_eval_proc(@partition_id_eval_proc sysname, @pubid uniqueidentifier,
                                                    @publication_number smallint, @column_list nvarchar(2000),
                                                    @function_list nvarchar(2000),
                                                    @partition_id_eval_clause nvarchar(2000),
                                                    @use_partition_groups smallint) as
-- missing source code
go

create procedure sys.sp_MSget_publication_from_taskname(@taskname sysname, @publisher sysname, @publisherdb sysname,
                                                        @publication sysname) as
-- missing source code
go

create procedure sys.sp_MSget_publisher_rpc(@trigger_id int, @connect_string nvarchar(2000), @owner sysname) as
-- missing source code
go

create procedure sys.sp_MSget_repl_cmds_anonymous(@agent_id int, @last_xact_seqno varbinary(16), @no_init_sync bit,
                                                  @get_count tinyint, @compatibility_level int) as
-- missing source code
go

create procedure sys.sp_MSget_repl_commands(@agent_id int, @last_xact_seqno varbinary(16), @get_count tinyint,
                                            @compatibility_level int, @subdb_version int, @read_query_size int) as
-- missing source code
go

create procedure sys.sp_MSget_repl_error(@id int) as
-- missing source code
go

create procedure sys.sp_MSget_server_portinfo(@name sysname, @srvname sysname, @srvname_with_port sysname) as
-- missing source code
go

create procedure sys.sp_MSget_session_statistics(@session_id int) as
-- missing source code
go

create procedure sys.sp_MSget_shared_agent(@server_name sysname, @database_name sysname, @agent_type int,
                                           @publisher sysname, @publisher_db sysname) as
-- missing source code
go

create procedure sys.sp_MSget_snapshot_history(@agent_id int, @timestamp timestamp, @rowcount int) as
-- missing source code
go

create procedure sys.sp_MSget_subscriber_partition_id(@publication sysname, @partition_id int, @maxgen_whenadded bigint,
                                                      @host_name_override sysname, @suser_sname_override sysname) as
-- missing source code
go

create procedure sys.sp_MSget_subscription_dts_info(@job_id varbinary(16)) as
-- missing source code
go

create procedure sys.sp_MSget_subscription_guid(@agent_id int) as
-- missing source code
go

create procedure sys.sp_MSget_synctran_commands(@publication sysname, @article sysname, @command_only bit,
                                                @publisher sysname, @publisher_db sysname, @alter bit, @trig_only bit,
                                                @usesqlclr bit) as
-- missing source code
go

create procedure sys.sp_MSget_type_wrapper(@tabid int, @colid int, @colname sysname, @typestring nvarchar(4000)) as
-- missing source code
go

create procedure sys.sp_MSgetagentoffloadinfo(@job_id varbinary(16)) as
-- missing source code
go

create procedure sys.sp_MSgetalertinfo(@includeaddresses bit) as
-- missing source code
go

create procedure sys.sp_MSgetalternaterecgens(@repid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSgetarticlereinitvalue(@subscriber sysname, @subscriberdb sysname, @publication sysname,
                                                @artid int, @reinit int) as
-- missing source code
go

create procedure sys.sp_MSgetchangecount(@startgen bigint, @changes int, @updates int, @deletes int) as
-- missing source code
go

create procedure sys.sp_MSgetconflictinsertproc(@artid uniqueidentifier, @pubid uniqueidentifier, @output int,
                                                @force_generate_proc bit) as
-- missing source code
go

create procedure sys.sp_MSgetconflicttablename(@publication sysname, @source_object nvarchar(520),
                                               @conflict_table sysname) as
-- missing source code
go

create procedure sys.sp_MSgetdatametadatabatch(@pubid uniqueidentifier, @tablenickarray varbinary(2000),
                                               @rowguidarray varbinary(8000),
                                               @all_articles_are_guaranteed_to_be_updateable_at_other_replica bit,
                                               @logical_record_parent_rowguid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSgetdbversion(@current_version int) as
-- missing source code
go

create procedure sys.sp_MSgetdynamicsnapshotapplock(@publication sysname, @partition_id int, @lock_acquired int,
                                                    @timeout int) as
-- missing source code
go

create procedure sys.sp_MSgetdynsnapvalidationtoken(@publication sysname, @dynamic_filter_login sysname) as
-- missing source code
go

create procedure sys.sp_MSgetgenstatus4rows(@repid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSgetisvalidwindowsloginfromdistributor(@login nvarchar(257), @isvalid bit, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_MSgetlastrecgen(@repid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSgetlastsentgen(@repid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSgetlastsentrecgens(@repid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSgetlastupdatedtime(@publisher sysname, @publisher_db sysname, @publication sysname,
                                             @subscription_type int, @publication_type int) as
-- missing source code
go

create procedure sys.sp_MSgetlightweightmetadatabatch(@pubid uniqueidentifier, @artnickarray varbinary(2000),
                                                      @rowguidarray varbinary(8000)) as
-- missing source code
go

create procedure sys.sp_MSgetmakegenerationapplock(@head_of_queue int) as
-- missing source code
go

create procedure sys.sp_MSgetmakegenerationapplock_90(@wait_time int, @lock_acquired int) as
-- missing source code
go

create procedure sys.sp_MSgetmaxbcpgen(@max_closed_gen bigint) as
-- missing source code
go

create procedure sys.sp_MSgetmaxsnapshottimestamp(@agent_id int, @timestamp timestamp) as
-- missing source code
go

create procedure sys.sp_MSgetmergeadminapplock(@timeout int, @lockmode nvarchar(32), @lock_acquired int,
                                               @lockowner nvarchar(32)) as
-- missing source code
go

create procedure sys.sp_MSgetmetadata_changedlogicalrecordmembers(@parent_rowguid uniqueidentifier, @commongen bigint,
                                                                  @parent_nickname int) as
-- missing source code
go

create procedure sys.sp_MSgetmetadatabatch(@pubid uniqueidentifier, @tablenickarray varbinary(2000),
                                           @rowguidarray varbinary(8000), @compatlevel int, @lightweight int) as
-- missing source code
go

create procedure sys.sp_MSgetmetadatabatch90(@pubid uniqueidentifier, @tablenickarray varbinary(2000),
                                             @rowguidarray varbinary(8000)) as
-- missing source code
go

create procedure sys.sp_MSgetmetadatabatch90new(@pubid uniqueidentifier, @tablenick int, @rowguid1 uniqueidentifier,
                                                @rowguid2 uniqueidentifier, @rowguid3 uniqueidentifier,
                                                @rowguid4 uniqueidentifier, @rowguid5 uniqueidentifier,
                                                @rowguid6 uniqueidentifier, @rowguid7 uniqueidentifier,
                                                @rowguid8 uniqueidentifier, @rowguid9 uniqueidentifier,
                                                @rowguid10 uniqueidentifier, @rowguid11 uniqueidentifier,
                                                @rowguid12 uniqueidentifier, @rowguid13 uniqueidentifier,
                                                @rowguid14 uniqueidentifier, @rowguid15 uniqueidentifier,
                                                @rowguid16 uniqueidentifier, @rowguid17 uniqueidentifier,
                                                @rowguid18 uniqueidentifier, @rowguid19 uniqueidentifier,
                                                @rowguid20 uniqueidentifier, @rowguid21 uniqueidentifier,
                                                @rowguid22 uniqueidentifier, @rowguid23 uniqueidentifier,
                                                @rowguid24 uniqueidentifier, @rowguid25 uniqueidentifier,
                                                @rowguid26 uniqueidentifier, @rowguid27 uniqueidentifier,
                                                @rowguid28 uniqueidentifier, @rowguid29 uniqueidentifier,
                                                @rowguid30 uniqueidentifier, @rowguid31 uniqueidentifier,
                                                @rowguid32 uniqueidentifier, @rowguid33 uniqueidentifier,
                                                @rowguid34 uniqueidentifier, @rowguid35 uniqueidentifier,
                                                @rowguid36 uniqueidentifier, @rowguid37 uniqueidentifier,
                                                @rowguid38 uniqueidentifier, @rowguid39 uniqueidentifier,
                                                @rowguid40 uniqueidentifier, @rowguid41 uniqueidentifier,
                                                @rowguid42 uniqueidentifier, @rowguid43 uniqueidentifier,
                                                @rowguid44 uniqueidentifier, @rowguid45 uniqueidentifier,
                                                @rowguid46 uniqueidentifier, @rowguid47 uniqueidentifier,
                                                @rowguid48 uniqueidentifier, @rowguid49 uniqueidentifier,
                                                @rowguid50 uniqueidentifier, @rowguid51 uniqueidentifier,
                                                @rowguid52 uniqueidentifier, @rowguid53 uniqueidentifier,
                                                @rowguid54 uniqueidentifier, @rowguid55 uniqueidentifier,
                                                @rowguid56 uniqueidentifier, @rowguid57 uniqueidentifier,
                                                @rowguid58 uniqueidentifier, @rowguid59 uniqueidentifier,
                                                @rowguid60 uniqueidentifier, @rowguid61 uniqueidentifier,
                                                @rowguid62 uniqueidentifier, @rowguid63 uniqueidentifier,
                                                @rowguid64 uniqueidentifier, @rowguid65 uniqueidentifier,
                                                @rowguid66 uniqueidentifier, @rowguid67 uniqueidentifier,
                                                @rowguid68 uniqueidentifier, @rowguid69 uniqueidentifier,
                                                @rowguid70 uniqueidentifier, @rowguid71 uniqueidentifier,
                                                @rowguid72 uniqueidentifier, @rowguid73 uniqueidentifier,
                                                @rowguid74 uniqueidentifier, @rowguid75 uniqueidentifier,
                                                @rowguid76 uniqueidentifier, @rowguid77 uniqueidentifier,
                                                @rowguid78 uniqueidentifier, @rowguid79 uniqueidentifier,
                                                @rowguid80 uniqueidentifier, @rowguid81 uniqueidentifier,
                                                @rowguid82 uniqueidentifier, @rowguid83 uniqueidentifier,
                                                @rowguid84 uniqueidentifier, @rowguid85 uniqueidentifier,
                                                @rowguid86 uniqueidentifier, @rowguid87 uniqueidentifier,
                                                @rowguid88 uniqueidentifier, @rowguid89 uniqueidentifier,
                                                @rowguid90 uniqueidentifier, @rowguid91 uniqueidentifier,
                                                @rowguid92 uniqueidentifier, @rowguid93 uniqueidentifier,
                                                @rowguid94 uniqueidentifier, @rowguid95 uniqueidentifier,
                                                @rowguid96 uniqueidentifier, @rowguid97 uniqueidentifier,
                                                @rowguid98 uniqueidentifier, @rowguid99 uniqueidentifier,
                                                @rowguid100 uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSgetonerow(@tablenick int, @rowguid uniqueidentifier, @pubid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSgetonerowlightweight(@tablenick int, @rowguid uniqueidentifier, @pubid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSgetpeerconflictrow(@originator_id nvarchar(32), @origin_datasource nvarchar(32),
                                             @tran_id nvarchar(32), @row_id nvarchar(32),
                                             @conflict_table nvarchar(270)) as
-- missing source code
go

create procedure sys.sp_MSgetpeerlsns(@publication sysname, @xlockrows bit) as
-- missing source code
go

create procedure sys.sp_MSgetpeertopeercommands(@publication sysname, @article sysname, @snapshot_lsn varbinary(16),
                                                @script_txt nvarchar(max)) as
-- missing source code
go

create procedure sys.sp_MSgetpeerwinnerrow(@originator_id nvarchar(32), @row_id nvarchar(19),
                                           @conflict_table nvarchar(270)) as
-- missing source code
go

create procedure sys.sp_MSgetpubinfo(@publication sysname, @publisher sysname, @pubdb sysname) as
-- missing source code
go

create procedure sys.sp_MSgetreplicainfo(@publisher sysname, @publisher_db sysname, @publication sysname,
                                         @datasource_type int, @server_name sysname, @db_name sysname,
                                         @datasource_path nvarchar(255), @compatlevel int) as
-- missing source code
go

create procedure sys.sp_MSgetreplicastate(@pubid uniqueidentifier, @subid uniqueidentifier,
                                          @replicastate uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSgetrowmetadata(@tablenick int, @rowguid uniqueidentifier, @generation bigint, @type tinyint,
                                         @lineage varbinary(311), @colv varbinary(2953), @pubid uniqueidentifier,
                                         @compatlevel int) as
-- missing source code
go

create procedure sys.sp_MSgetrowmetadatalightweight(@tablenick int, @rowguid uniqueidentifier, @type tinyint,
                                                    @rowvector varbinary(11), @changedcolumns varbinary(128),
                                                    @columns_enumeration tinyint, @pubid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSgetsetupbelong_cost() as
-- missing source code
go

create procedure sys.sp_MSgetsubscriberinfo(@pubid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSgetsupportabilitysettings(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                    @server_name sysname, @db_name sysname, @web_server sysname,
                                                    @compatlevel int) as
-- missing source code
go

create procedure sys.sp_MSgettrancftsrcrow(@tran_id sysname, @row_id sysname, @conflict_table nvarchar(270),
                                           @is_subscriber bit, @is_debug bit) as
-- missing source code
go

create procedure sys.sp_MSgettranconflictrow(@tran_id sysname, @row_id sysname, @conflict_table nvarchar(270),
                                             @is_subscriber bit) as
-- missing source code
go

create procedure sys.sp_MSgetversion() as
-- missing source code
go

create procedure sys.sp_MSgrantconnectreplication(@user_name sysname) as
-- missing source code
go

create procedure sys.sp_MShaschangeslightweight(@pubid uniqueidentifier, @haschanges int) as
-- missing source code
go

create procedure sys.sp_MShasdbaccess() as
-- missing source code
go

create procedure sys.sp_MShelp_article(@publisher sysname, @publisher_db sysname, @publication sysname,
                                       @article sysname) as
-- missing source code
go

create procedure sys.sp_MShelp_distdb(@publisher_name sysname) as
-- missing source code
go

create procedure sys.sp_MShelp_distribution_agentid(@publisher_id smallint, @publisher_db sysname, @publication sysname,
                                                    @subscriber_id smallint, @subscriber_db sysname,
                                                    @subscription_type int, @subscriber_name sysname,
                                                    @anonymous_subid uniqueidentifier, @reinitanon bit) as
-- missing source code
go

create procedure sys.sp_MShelp_identity_property(@tablename sysname, @ownername sysname) as
-- missing source code
go

create procedure sys.sp_MShelp_logreader_agentid(@publisher_id smallint, @publisher_db sysname) as
-- missing source code
go

create procedure sys.sp_MShelp_merge_agentid(@publisher_id smallint, @publisher_db sysname, @publication sysname,
                                             @subscriber_id smallint, @subscriber_db sysname, @subscriber_version int,
                                             @subscriber sysname) as
-- missing source code
go

create procedure sys.sp_MShelp_profile(@agent_id int, @agent_type int, @profile_name sysname) as
-- missing source code
go

create procedure sys.sp_MShelp_profilecache(@profile_name sysname) as
-- missing source code
go

create procedure sys.sp_MShelp_publication(@publisher sysname, @publisher_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_MShelp_repl_agent(@publisher sysname, @publisher_db sysname, @publication sysname,
                                          @subscriber sysname, @subscriber_db sysname, @agent_type int) as
-- missing source code
go

create procedure sys.sp_MShelp_replication_status(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                  @agent_type int, @exclude_anonymous bit) as
-- missing source code
go

create procedure sys.sp_MShelp_replication_table(@table_name sysname, @table_owner sysname) as
-- missing source code
go

create procedure sys.sp_MShelp_snapshot_agent(@agent_id int) as
-- missing source code
go

create procedure sys.sp_MShelp_snapshot_agentid(@publisher_id smallint, @publisher_db sysname, @publication sysname,
                                                @job_id binary(16), @dynamic_snapshot_location nvarchar(255),
                                                @dynamic_filter_login sysname, @dynamic_filter_hostname sysname) as
-- missing source code
go

create procedure sys.sp_MShelp_subscriber_info(@publisher sysname, @subscriber sysname, @found int,
                                               @show_password bit) as
-- missing source code
go

create procedure sys.sp_MShelp_subscription(@publisher sysname, @publisher_db sysname, @publication sysname,
                                            @subscriber sysname, @subscriber_db sysname) as
-- missing source code
go

create procedure sys.sp_MShelp_subscription_status(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                   @subscriber sysname, @subscriber_db sysname, @retention int,
                                                   @out_of_date int, @independent_agent bit) as
-- missing source code
go

create procedure sys.sp_MShelpcolumns(@tablename nvarchar(517), @flags int, @orderby nvarchar(10), @flags2 int) as
-- missing source code
go

create procedure sys.sp_MShelpconflictpublications(@publication_type varchar(9)) as
-- missing source code
go

create procedure sys.sp_MShelpcreatebeforetable(@objid int, @newname sysname) as
-- missing source code
go

create procedure sys.sp_MShelpdestowner(@spname sysname) as
-- missing source code
go

create procedure sys.sp_MShelpdynamicsnapshotjobatdistributor(@publisher sysname, @publisher_db sysname,
                                                              @publication sysname, @dynamic_filter_login sysname,
                                                              @dynamic_filter_hostname sysname, @frequency_type int,
                                                              @frequency_interval int, @frequency_subday int,
                                                              @frequency_subday_interval int,
                                                              @frequency_relative_interval int,
                                                              @frequency_recurrence_factor int, @active_start_date int,
                                                              @active_end_date int, @active_start_time_of_day int,
                                                              @active_end_time_of_day int) as
-- missing source code
go

create procedure sys.sp_MShelpfulltextindex(@tablename nvarchar(517)) as
-- missing source code
go

create procedure sys.sp_MShelpfulltextscript(@tablename nvarchar(517)) as
-- missing source code
go

create procedure sys.sp_MShelpindex(@tablename nvarchar(517), @indexname nvarchar(258), @flags int) as
-- missing source code
go

create procedure sys.sp_MShelplogreader_agent(@publisher sysname, @publisher_db sysname) as
-- missing source code
go

create procedure sys.sp_MShelpmergearticles(@publication sysname, @compatibility_level int,
                                            @pubidin uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MShelpmergeconflictcounts(@publication_name sysname, @publisher sysname, @publisher_db sysname,
                                                  @logical_record_conflicts int) as
-- missing source code
go

create procedure sys.sp_MShelpmergedynamicsnapshotjob(@publication sysname, @dynamic_snapshot_jobname sysname,
                                                      @dynamic_snapshot_jobid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MShelpmergeidentity(@publication sysname) as
-- missing source code
go

create procedure sys.sp_MShelpmergeschemaarticles(@publication sysname) as
-- missing source code
go

create procedure sys.sp_MShelpobjectpublications(@object_name sysname) as
-- missing source code
go

create procedure sys.sp_MShelpreplicationtriggers(@object_name sysname, @object_schema sysname) as
-- missing source code
go

create procedure sys.sp_MShelpsnapshot_agent(@publisher sysname, @publisher_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_MShelpsummarypublication(@oename nvarchar(260), @oetype nvarchar(100)) as
-- missing source code
go

create procedure sys.sp_MShelptracertokenhistory(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                 @tracer_id int) as
-- missing source code
go

create procedure sys.sp_MShelptracertokens(@publisher sysname, @publisher_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_MShelptranconflictcounts(@publication_name sysname, @publisher sysname, @publisher_db sysname,
                                                 @originator_id nvarchar(32)) as
-- missing source code
go

create procedure sys.sp_MShelptype(@typename nvarchar(517), @flags nvarchar(10)) as
-- missing source code
go

create procedure sys.sp_MShelpvalidationdate(@publication sysname, @subscriber sysname, @subscriber_db sysname) as
-- missing source code
go

create procedure sys.sp_MSindexspace(@tablename nvarchar(517), @index_name nvarchar(258)) as
-- missing source code
go

create procedure sys.sp_MSinit_publication_access(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                  @initinfo nvarchar(max), @skip bit) as
-- missing source code
go

create procedure sys.sp_MSinit_subscription_agent(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                  @subscription_type int) as
-- missing source code
go

create procedure sys.sp_MSinitdynamicsubscriber(@maxrows int, @tablenick int, @rowguid uniqueidentifier,
                                                @pubid uniqueidentifier, @compatlevel int, @enumentirerowmetadata bit,
                                                @blob_cols_at_the_end bit) as
-- missing source code
go

create procedure sys.sp_MSinsert_identity(@publisher sysname, @publisher_db sysname, @tablename sysname,
                                          @identity_support int, @pub_identity_range bigint, @identity_range bigint,
                                          @threshold int, @next_seed bigint, @max_identity bigint) as
-- missing source code
go

create procedure sys.sp_MSinsertdeleteconflict(@tablenick int, @rowguid uniqueidentifier, @conflict_type int,
                                               @reason_code int, @reason_text nvarchar(720),
                                               @origin_datasource nvarchar(255), @pubid uniqueidentifier,
                                               @lineage varbinary(311), @conflicts_logged int, @compatlevel int,
                                               @source_id uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSinserterrorlineage(@tablenick int, @rowguid uniqueidentifier, @lineage varbinary(311),
                                             @compatlevel int) as
-- missing source code
go

create procedure sys.sp_MSinsertgenerationschemachanges(@publication sysname) as
-- missing source code
go

create procedure sys.sp_MSinsertgenhistory(@guidsrc uniqueidentifier, @gen bigint, @pubid uniqueidentifier,
                                           @pubid_ins uniqueidentifier, @nicknames varbinary(1000), @artnick int,
                                           @compatlevel int) as
-- missing source code
go

create procedure sys.sp_MSinsertlightweightschemachange(@pubid uniqueidentifier, @schemaversion int,
                                                        @schemaguid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSinsertschemachange(@pubid uniqueidentifier, @artid uniqueidentifier, @schemaversion int,
                                             @schemaguid uniqueidentifier, @schematype int, @schematext nvarchar(max),
                                             @schemasubtype int, @update_schemaversion tinyint) as
-- missing source code
go

create procedure sys.sp_MSinvalidate_snapshot(@publisher sysname, @publisher_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_MSisnonpkukupdateinconflict(@pubid int, @artid int, @bitmap varbinary(4000)) as
-- missing source code
go

create procedure sys.sp_MSispeertopeeragent(@agent_id int, @is_p2p int) as
-- missing source code
go

create procedure sys.sp_MSispkupdateinconflict(@pubid int, @artid int, @bitmap varbinary(4000)) as
-- missing source code
go

create procedure sys.sp_MSispublicationqueued(@publisher sysname, @publisher_db sysname, @publication sysname,
                                              @allow_queued_tran bit) as
-- missing source code
go

create procedure sys.sp_MSisreplmergeagent(@is_merge bit, @at_publisher bit) as
-- missing source code
go

create procedure sys.sp_MSissnapshotitemapplied(@snapshot_session_token nvarchar(260),
                                                @snapshot_progress_token nvarchar(500)) as
-- missing source code
go

create procedure sys.sp_MSkilldb(@dbname nvarchar(258)) as
-- missing source code
go

create procedure sys.sp_MSlock_auto_sub(@publisher_id int, @publisher_db sysname, @publication sysname, @reset bit) as
-- missing source code
go

create procedure sys.sp_MSlock_distribution_agent(@id int, @mode int) as
-- missing source code
go

create procedure sys.sp_MSlocktable(@ownername sysname, @tablename sysname) as
-- missing source code
go

create procedure sys.sp_MSloginmappings(@loginname nvarchar(258), @flags int) as
-- missing source code
go

create procedure sys.sp_MSmakearticleprocs(@pubid uniqueidentifier, @artid uniqueidentifier,
                                           @recreate_conflict_proc bit) as
-- missing source code
go

create procedure sys.sp_MSmakebatchinsertproc(@tablename sysname, @ownername sysname, @procname sysname,
                                              @pubid uniqueidentifier, @artid uniqueidentifier,
                                              @generate_subscriber_proc bit, @destination_owner sysname) as
-- missing source code
go

create procedure sys.sp_MSmakebatchupdateproc(@tablename sysname, @ownername sysname, @procname sysname,
                                              @pubid uniqueidentifier, @artid uniqueidentifier,
                                              @generate_subscriber_proc bit, @destination_owner sysname) as
-- missing source code
go

create procedure sys.sp_MSmakeconflictinsertproc(@tablename sysname, @ownername sysname, @procname sysname,
                                                 @basetableid int, @pubid uniqueidentifier,
                                                 @generate_subscriber_proc bit) as
-- missing source code
go

create procedure sys.sp_MSmakectsview(@publication sysname, @ctsview sysname,
                                      @dynamic_snapshot_views_table_name sysname, @create_dynamic_views bit,
                                      @max_bcp_gen bigint) as
-- missing source code
go

create procedure sys.sp_MSmakedeleteproc(@tablename sysname, @ownername sysname, @procname sysname,
                                         @pubid uniqueidentifier, @artid uniqueidentifier,
                                         @generate_subscriber_proc bit, @destination_owner sysname) as
-- missing source code
go

create procedure sys.sp_MSmakedynsnapshotvws(@publication sysname, @dynamic_filter_login sysname,
                                             @dynamic_snapshot_views_table_name sysname) as
-- missing source code
go

create procedure sys.sp_MSmakeexpandproc(@pubname sysname, @filterid int, @procname sysname) as
-- missing source code
go

create procedure sys.sp_MSmakegeneration(@gencheck int, @commongen bigint, @commongenguid uniqueidentifier,
                                         @commongenvalid int, @compatlevel int) as
-- missing source code
go

create procedure sys.sp_MSmakeinsertproc(@tablename sysname, @ownername sysname, @procname sysname,
                                         @pubid uniqueidentifier, @artid uniqueidentifier,
                                         @generate_downlevel_procs bit, @generate_subscriber_proc bit,
                                         @destination_owner sysname) as
-- missing source code
go

create procedure sys.sp_MSmakemetadataselectproc(@tablename sysname, @ownername sysname, @procname sysname,
                                                 @pubid uniqueidentifier, @artid uniqueidentifier,
                                                 @generate_subscriber_proc bit, @destination_owner sysname) as
-- missing source code
go

create procedure sys.sp_MSmakeselectproc(@tablename sysname, @ownername sysname, @procname sysname,
                                         @pubid uniqueidentifier, @artid uniqueidentifier,
                                         @generate_downlevel_procs bit, @generate_subscriber_proc bit,
                                         @destination_owner sysname) as
-- missing source code
go

create procedure sys.sp_MSmakesystableviews(@publication sysname, @dynamic_snapshot_views_table_name sysname,
                                            @create_dynamic_views bit, @max_bcp_gen bigint) as
-- missing source code
go

create procedure sys.sp_MSmakeupdateproc(@tablename sysname, @ownername sysname, @procname sysname,
                                         @pubid uniqueidentifier, @artid uniqueidentifier,
                                         @generate_downlevel_procs bit, @generate_subscriber_proc bit,
                                         @destination_owner sysname) as
-- missing source code
go

create procedure sys.sp_MSmap_partitionid_to_generations(@partition_id int) as
-- missing source code
go

create procedure sys.sp_MSmarkreinit(@publisher sysname, @publisher_db sysname, @publication sysname,
                                     @subscriber sysname, @subscriber_db sysname, @reset_reinit int) as
-- missing source code
go

create procedure sys.sp_MSmatchkey(@tablename nvarchar(517), @col1 nvarchar(258), @col2 nvarchar(258),
                                   @col3 nvarchar(258), @col4 nvarchar(258), @col5 nvarchar(258), @col6 nvarchar(258),
                                   @col7 nvarchar(258), @col8 nvarchar(258), @col9 nvarchar(258), @col10 nvarchar(258),
                                   @col11 nvarchar(258), @col12 nvarchar(258), @col13 nvarchar(258),
                                   @col14 nvarchar(258), @col15 nvarchar(258), @col16 nvarchar(258)) as
-- missing source code
go

create procedure sys.sp_MSmerge_alterschemaonly(@qual_object_name nvarchar(512), @objid int,
                                                @pass_through_scripts nvarchar(max), @objecttype varchar(32)) as
-- missing source code
go

create procedure sys.sp_MSmerge_altertrigger(@qual_object_name nvarchar(512), @objid int,
                                             @pass_through_scripts nvarchar(max), @target_object_name nvarchar(512)) as
-- missing source code
go

create procedure sys.sp_MSmerge_alterview(@qual_object_name nvarchar(512), @objid int,
                                          @pass_through_scripts nvarchar(max), @objecttype varchar(32)) as
-- missing source code
go

create procedure sys.sp_MSmerge_ddldispatcher(@EventData xml, @procmapid int) as
-- missing source code
go

create procedure sys.sp_MSmerge_getgencount(@genlist varchar(8000), @gencount int) as
-- missing source code
go

create procedure sys.sp_MSmerge_getgencur_public(@tablenick int, @changecount int, @gen_cur bigint) as
-- missing source code
go

create procedure sys.sp_MSmerge_is_snapshot_required(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                     @subscriber sysname, @subscriber_db sysname,
                                                     @subscription_type int, @schemaversion bigint,
                                                     @run_at_subscriber bit) as
-- missing source code
go

create procedure sys.sp_MSmerge_log_identity_range_allocations(@publisher sysname, @publisher_db sysname,
                                                               @publication sysname, @article sysname,
                                                               @subscriber sysname, @subscriber_db sysname,
                                                               @is_pub_range bit, @ranges_allocated tinyint,
                                                               @range_begin numeric(38), @range_end numeric(38),
                                                               @next_range_begin numeric(38),
                                                               @next_range_end numeric(38)) as
-- missing source code
go

create procedure sys.sp_MSmerge_parsegenlist(@genlist varchar(8000), @gendeclarelist varchar(max),
                                             @genselectlist varchar(max), @genunionlist varchar(max)) as
-- missing source code
go

create procedure sys.sp_MSmerge_upgrade_subscriber(@upgrade_metadata bit, @upgrade_done bit) as
-- missing source code
go

create procedure sys.sp_MSmergesubscribedb(@value sysname, @create_ddl_triggers bit, @whattocreate smallint) as
-- missing source code
go

create procedure sys.sp_MSmergeupdatelastsyncinfo(@subid uniqueidentifier, @last_sync_status int,
                                                  @last_sync_summary sysname) as
-- missing source code
go

create procedure sys.sp_MSneedmergemetadataretentioncleanup(@replicaid uniqueidentifier, @needcleanup bit) as
-- missing source code
go

create procedure sys.sp_MSobjectprivs(@objname nvarchar(776), @mode nvarchar(10), @objid int, @srvpriv int,
                                      @prottype int, @grantee nvarchar(258), @flags int, @rollup int) as
-- missing source code
go

create procedure sys.sp_MSpeerapplyresponse(@request_id int, @originator sysname, @originator_db sysname,
                                            @response_srvr sysname, @response_db sysname) as
-- missing source code
go

create procedure sys.sp_MSpeerapplytopologyinfo(@request_id int, @originator sysname, @originator_db sysname,
                                                @response_srvr sysname, @response_db sysname, @connection_info xml,
                                                @response_srvr_version int, @response_originator_id int,
                                                @response_conflict_retention int) as
-- missing source code
go

create procedure sys.sp_MSpeerconflictdetection_statuscollection_applyresponse(@request_id int, @peer_node sysname,
                                                                               @peer_db sysname, @peer_db_version int,
                                                                               @conflictdetection_enabled bit,
                                                                               @peer_originator_id int,
                                                                               @peer_conflict_retention int,
                                                                               @peer_continue_onconflict bit,
                                                                               @peer_histids nvarchar(max),
                                                                               @originator_node sysname,
                                                                               @originator_db sysname) as
-- missing source code
go

create procedure sys.sp_MSpeerconflictdetection_statuscollection_sendresponse(@request_id int, @publication sysname,
                                                                              @originator_node sysname,
                                                                              @originator_db sysname) as
-- missing source code
go

create procedure sys.sp_MSpeerconflictdetection_topology_applyresponse(@request_id int, @peer_node sysname,
                                                                       @peer_db sysname, @peer_version int,
                                                                       @peer_subscriptions nvarchar(max)) as
-- missing source code
go

create procedure sys.sp_MSpeerdbinfo(@is_p2p bit, @current_version int) as
-- missing source code
go

create procedure sys.sp_MSpeersendresponse(@request_id int, @originator sysname, @originator_db sysname,
                                           @originator_publication sysname) as
-- missing source code
go

create procedure sys.sp_MSpeersendtopologyinfo(@request_id int, @originator sysname, @originator_db sysname,
                                               @originator_publication sysname) as
-- missing source code
go

create procedure sys.sp_MSpeertopeerfwdingexec(@command nvarchar(max), @publication sysname, @execute bit,
                                               @change_results_originator bit) as
-- missing source code
go

create procedure sys.sp_MSpost_auto_proc(@pubid int, @artid int, @procmapid int, @pubname sysname, @artname sysname,
                                         @publisher sysname, @dbname sysname, @for_p2p_ddl bit, @format int,
                                         @has_ts bit, @has_ident bit, @alter bit) as
-- missing source code
go

create procedure sys.sp_MSpostapplyscript_forsubscriberprocs(@procsuffix sysname) as
-- missing source code
go

create procedure sys.sp_MSprep_exclusive(@objname sysname, @objid int) as
-- missing source code
go

create procedure sys.sp_MSprepare_mergearticle(@source_owner sysname, @source_table sysname, @publication sysname,
                                               @qualified_tablename nvarchar(270)) as
-- missing source code
go

create procedure sys.sp_MSprofile_in_use(@tablename nvarchar(255), @profile_id int) as
-- missing source code
go

create procedure sys.sp_MSproxiedmetadata(@tablenick int, @rowguid uniqueidentifier, @proxied_lineage varbinary(311),
                                          @proxied_colv varbinary(2953), @proxy_logical_record_lineage bit,
                                          @compatlevel int) as
-- missing source code
go

create procedure sys.sp_MSproxiedmetadatabatch(@tablenick int, @rowguid uniqueidentifier,
                                               @proxied_lineage varbinary(311), @proxied_colv varbinary(2953),
                                               @proxy_logical_record_lineage bit, @compatlevel int) as
-- missing source code
go

create procedure sys.sp_MSproxiedmetadatalightweight(@tablenick int, @rowguid uniqueidentifier, @pubid uniqueidentifier,
                                                     @acknowledge_only bit, @rowvector varbinary(11)) as
-- missing source code
go

create procedure sys.sp_MSpub_adjust_identity(@artid int, @max_identity bigint) as
-- missing source code
go

create procedure sys.sp_MSpublication_access(@publisher sysname, @publisher_db sysname, @publication sysname,
                                             @login sysname, @operation nvarchar(20), @has_access bit, @skip bit) as
-- missing source code
go

create procedure sys.sp_MSpublicationcleanup(@publication sysname, @publisher_db sysname, @publisher sysname,
                                             @ignore_merge_metadata bit, @force_preserve_rowguidcol bit) as
-- missing source code
go

create procedure sys.sp_MSpublicationview(@publication sysname, @force_flag int, @max_network_optimization bit,
                                          @articlename sysname) as
-- missing source code
go

create procedure sys.sp_MSquery_syncstates(@publisher_id smallint, @publisher_db sysname) as
-- missing source code
go

create procedure sys.sp_MSquerysubtype(@pubid uniqueidentifier, @subscriber sysname, @subscriber_db sysname) as
-- missing source code
go

create procedure sys.sp_MSrecordsnapshotdeliveryprogress(@snapshot_session_token nvarchar(260),
                                                         @snapshot_progress_token nvarchar(500)) as
-- missing source code
go

create procedure sys.sp_MSreenable_check(@objname sysname, @objowner sysname) as
-- missing source code
go

create procedure sys.sp_MSrefresh_anonymous(@publication sysname, @publisher sysname, @publisher_db sysname) as
-- missing source code
go

create procedure sys.sp_MSrefresh_publisher_idrange(@qualified_object_name nvarchar(517), @subid uniqueidentifier,
                                                    @artid uniqueidentifier, @ranges_needed tinyint,
                                                    @refresh_check_constraint bit) as
-- missing source code
go

create procedure sys.sp_MSregenerate_mergetriggersprocs(@pubid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSregisterdynsnapseqno(@snapshot_session_token nvarchar(260), @dynsnapseqno uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSregistermergesnappubid(@snapshot_session_token nvarchar(260), @pubid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSregistersubscription(@replication_type int, @publisher sysname, @publisher_db sysname,
                                               @publisher_security_mode int, @publisher_login sysname,
                                               @publisher_password nvarchar(524), @publication sysname,
                                               @subscriber sysname, @subscriber_db sysname,
                                               @subscriber_security_mode int, @subscriber_login sysname,
                                               @subscriber_password nvarchar(524), @distributor sysname,
                                               @distributor_security_mode int, @distributor_login sysname,
                                               @distributor_password nvarchar(524), @subscription_id uniqueidentifier,
                                               @independent_agent int, @subscription_type int,
                                               @use_interactive_resolver int, @failover_mode int, @use_web_sync bit,
                                               @hostname sysname) as
-- missing source code
go

create procedure sys.sp_MSreinit_failed_subscriptions(@failure_level int) as
-- missing source code
go

create procedure sys.sp_MSreinit_hub(@publisher sysname, @publisher_db sysname, @publication sysname,
                                     @upload_first bit) as
-- missing source code
go

create procedure sys.sp_MSreinit_subscription(@publisher_name sysname, @publisher_db sysname, @publication sysname,
                                              @subscriber_name sysname, @subscriber_db sysname) as
-- missing source code
go

create procedure sys.sp_MSreinitoverlappingmergepublications(@pubid uniqueidentifier, @upload_before_reinit bit) as
-- missing source code
go

create procedure sys.sp_MSreleaseSlotLock(@process_name sysname, @DbPrincipal sysname) as
-- missing source code
go

create procedure sys.sp_MSreleasedynamicsnapshotapplock(@publication sysname, @partition_id int) as
-- missing source code
go

create procedure sys.sp_MSreleasemakegenerationapplock() as
-- missing source code
go

create procedure sys.sp_MSreleasemergeadminapplock(@lockowner nvarchar(32)) as
-- missing source code
go

create procedure sys.sp_MSreleasesnapshotdeliverysessionlock() as
-- missing source code
go

create procedure sys.sp_MSremove_mergereplcommand(@publication sysname, @article sysname, @schematype int) as
-- missing source code
go

create procedure sys.sp_MSremoveoffloadparameter(@job_id varbinary(16), @agenttype nvarchar(20)) as
-- missing source code
go

create procedure sys.sp_MSrepl_FixPALRole(@pubid uniqueidentifier, @role sysname) as
-- missing source code
go

create procedure sys.sp_MSrepl_IsLastPubInSharedSubscription(@subscriber sysname, @subscriber_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_MSrepl_IsUserInAnyPAL(@raise_error bit) as
-- missing source code
go

create procedure sys.sp_MSrepl_PAL_rolecheck(@publication sysname, @artid uniqueidentifier, @repid uniqueidentifier,
                                             @pubid uniqueidentifier, @objid int, @tablenick int, @partition_id int) as
-- missing source code
go

create procedure sys.sp_MSrepl_agentstatussummary(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                  @snap_status int, @snap_time datetime, @snap_comments nvarchar(255),
                                                  @snap_duration int, @log_status int, @log_time datetime,
                                                  @log_comments nvarchar(255), @log_duration int) as
-- missing source code
go

create procedure sys.sp_MSrepl_backup_complete() as
-- missing source code
go

create procedure sys.sp_MSrepl_backup_start() as
-- missing source code
go

create procedure sys.sp_MSrepl_check_publisher(@publisher_type sysname, @publisher sysname, @security_mode bit,
                                               @login nvarchar(255), @password nvarchar(255), @connect_timeout int) as
-- missing source code
go

create procedure sys.sp_MSrepl_createdatatypemappings() as
-- missing source code
go

create procedure sys.sp_MSrepl_distributionagentstatussummary(@publisher sysname, @publisher_db sysname,
                                                              @publication sysname, @subscriber sysname,
                                                              @subscriber_db sysname, @distribution_status int,
                                                              @distribution_message nvarchar(255),
                                                              @distribution_time datetime,
                                                              @distribution_duration int) as
-- missing source code
go

create procedure sys.sp_MSrepl_dropdatatypemappings() as
-- missing source code
go

create procedure sys.sp_MSrepl_enumarticlecolumninfo(@publisher sysname, @publication sysname, @article sysname,
                                                     @defaults bit) as
-- missing source code
go

create procedure sys.sp_MSrepl_enumpublications(@reserved bit) as
-- missing source code
go

create procedure sys.sp_MSrepl_enumpublishertables(@publisher sysname, @silent bit) as
-- missing source code
go

create procedure sys.sp_MSrepl_enumsubscriptions(@publication sysname, @publisher sysname, @reserved bit) as
-- missing source code
go

create procedure sys.sp_MSrepl_enumtablecolumninfo(@publisher sysname, @owner sysname, @tablename sysname) as
-- missing source code
go

create procedure sys.sp_MSrepl_getdistributorinfo(@distributor sysname, @distribdb sysname, @publisher sysname,
                                                  @local nvarchar(5), @rpcsrvname sysname, @publisher_type sysname,
                                                  @publisher_id int, @working_directory nvarchar(255), @version int,
                                                  @dist_listener sysname, @is_DistribDB_in_AG bit) as
-- missing source code
go

create procedure sys.sp_MSrepl_getpkfkrelation(@filtered_table nvarchar(400), @joined_table nvarchar(400)) as
-- missing source code
go

create procedure sys.sp_MSrepl_gettype_mappings(@dbms_name sysname, @dbms_version sysname, @sql_type sysname,
                                                @source_prec int) as
-- missing source code
go

create procedure sys.sp_MSrepl_helparticlermo(@publication sysname, @article sysname, @returnfilter bit,
                                              @publisher sysname, @found int) as
-- missing source code
go

create procedure sys.sp_MSrepl_init_backup_lsns() as
-- missing source code
go

create procedure sys.sp_MSrepl_isdbowner(@dbname sysname) as
-- missing source code
go

create procedure sys.sp_MSrepl_linkedservers_rowset(@srvname sysname, @agent_id int, @agent_type int) as
-- missing source code
go

create procedure sys.sp_MSrepl_mergeagentstatussummary(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                       @subscriber sysname, @subscriber_db sysname, @merge_status int,
                                                       @merge_message nvarchar(1000), @merge_time datetime,
                                                       @merge_duration int, @merge_percent_complete decimal(5, 2)) as
-- missing source code
go

create procedure sys.sp_MSrepl_monitor_job_at_failover(@database_name sysname, @all bit) as
-- missing source code
go

create procedure sys.sp_MSrepl_raiserror(@agent sysname, @agent_name nvarchar(100), @status int, @message nvarchar(255),
                                         @subscriber sysname, @publication sysname, @article sysname) as
-- missing source code
go

create procedure sys.sp_MSrepl_reinit_jobsync_table(@database_name sysname, @all bit) as
-- missing source code
go

create procedure sys.sp_MSrepl_schema(@pubname sysname, @artid int, @qual_source_object nvarchar(517), @column sysname,
                                      @operation int, @typetext nvarchar(3000), @schema_change_script nvarchar(4000)) as
-- missing source code
go

create procedure sys.sp_MSrepl_setNFR(@schema sysname, @object_name sysname) as
-- missing source code
go

create procedure sys.sp_MSrepl_snapshot_helparticlecolumns(@publication sysname, @article sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_MSrepl_snapshot_helppublication(@publication sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_MSrepl_startup_internal() as
-- missing source code
go

create procedure sys.sp_MSrepl_subscription_rowset(@subscriber sysname, @agent_id int, @agent_type int) as
-- missing source code
go

create procedure sys.sp_MSrepl_testadminconnection(@distributor sysname, @password sysname) as
-- missing source code
go

create procedure sys.sp_MSrepl_testconnection(@publisher_type sysname, @publisher sysname, @security_mode bit,
                                              @login sysname, @password sysname, @connect_timeout int) as
-- missing source code
go

create procedure sys.sp_MSreplagentjobexists(@type int, @exists bit, @job_name sysname, @job_id uniqueidentifier,
                                             @job_step_uid uniqueidentifier, @proxy_id int, @publisher_id int,
                                             @subscriber_id int, @publisher sysname, @publisher_db sysname,
                                             @publication sysname, @subscriber sysname, @subscriber_db sysname,
                                             @independent_agent bit, @frompublisher bit) as
-- missing source code
go

create procedure sys.sp_MSreplcheck_permission(@objid int, @type int, @permissions int) as
-- missing source code
go

create procedure sys.sp_MSreplcheck_pull(@publication sysname, @raise_fatal_error bit, @pubid uniqueidentifier,
                                         @given_login sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_MSreplcheck_subscribe() as
-- missing source code
go

create procedure sys.sp_MSreplcheck_subscribe_withddladmin() as
-- missing source code
go

create procedure sys.sp_MSreplcheckoffloadserver(@offloadserver sysname) as
-- missing source code
go

create procedure sys.sp_MSreplcopyscriptfile(@directory nvarchar(4000), @scriptfile nvarchar(4000)) as
-- missing source code
go

create procedure sys.sp_MSreplraiserror(@errorid int, @param1 sysname, @param2 sysname, @param3 int) as
-- missing source code
go

create procedure sys.sp_MSreplremoveuncdir(@dir nvarchar(260), @ignore_errors bit) as
-- missing source code
go

create procedure sys.sp_MSreplupdateschema(@object_name nvarchar(517)) as
-- missing source code
go

create procedure sys.sp_MSrequestreenumeration(@tablenick int, @rowguid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSrequestreenumeration_lightweight(@tablenick int, @rowguid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSreset_attach_state(@publisher sysname, @publisher_db sysname, @publication sysname,
                                             @subscription_type int) as
-- missing source code
go

create procedure sys.sp_MSreset_queued_reinit(@subscriber sysname, @subscriber_db sysname, @artid int) as
-- missing source code
go

create procedure sys.sp_MSreset_subscription(@publisher sysname, @publisher_db sysname, @publication sysname,
                                             @subscriber sysname, @subscriber_db sysname, @subscription_type int) as
-- missing source code
go

create procedure sys.sp_MSreset_subscription_seqno(@agent_id int, @get_snapshot bit) as
-- missing source code
go

create procedure sys.sp_MSreset_synctran_bit(@owner sysname, @table sysname) as
-- missing source code
go

create procedure sys.sp_MSreset_transaction(@publisher sysname, @publisher_db sysname, @xact_seqno varbinary(10)) as
-- missing source code
go

create procedure sys.sp_MSresetsnapshotdeliveryprogress(@snapshot_session_token nvarchar(260)) as
-- missing source code
go

create procedure sys.sp_MSrestoresavedforeignkeys(@program_name sysname) as
-- missing source code
go

create procedure sys.sp_MSretrieve_publication_attributes(@name sysname, @database sysname) as
-- missing source code
go

create procedure sys.sp_MSscript_article_view(@artid int, @view_name sysname, @include_timestamps bit) as
-- missing source code
go

create procedure sys.sp_MSscript_dri(@publication sysname, @article sysname) as
-- missing source code
go

create procedure sys.sp_MSscript_pub_upd_trig(@publication sysname, @article sysname, @procname sysname, @alter bit) as
-- missing source code
go

create procedure sys.sp_MSscript_sync_del_proc(@publication sysname, @article sysname, @procname sysname, @alter bit) as
-- missing source code
go

create procedure sys.sp_MSscript_sync_del_trig(@objid int, @publisher sysname, @publisher_db sysname,
                                               @publication sysname, @trigname sysname, @procname sysname,
                                               @proc_owner sysname, @cftproc sysname, @agent_id int,
                                               @identity_col sysname, @ts_col sysname, @filter_clause nvarchar(4000),
                                               @primary_key_bitmap varbinary(4000), @pubversion int, @falter bit) as
-- missing source code
go

create procedure sys.sp_MSscript_sync_ins_proc(@publication sysname, @article sysname, @procname sysname, @alter bit) as
-- missing source code
go

create procedure sys.sp_MSscript_sync_ins_trig(@objid int, @publisher sysname, @publisher_db sysname,
                                               @publication sysname, @trigname sysname, @procname sysname,
                                               @proc_owner sysname, @cftproc sysname, @agent_id int,
                                               @identity_col sysname, @ts_col sysname, @filter_clause nvarchar(4000),
                                               @primary_key_bitmap varbinary(4000), @pubversion int, @falter bit) as
-- missing source code
go

create procedure sys.sp_MSscript_sync_upd_proc(@publication sysname, @article sysname, @procname sysname, @alter bit) as
-- missing source code
go

create procedure sys.sp_MSscript_sync_upd_trig(@objid int, @publisher sysname, @publisher_db sysname,
                                               @publication sysname, @trigname sysname, @procname sysname,
                                               @proc_owner sysname, @cftproc sysname, @agent_id int,
                                               @identity_col sysname, @ts_col sysname, @filter_clause nvarchar(4000),
                                               @primary_key_bitmap varbinary(4000), @pubversion int, @falter bit) as
-- missing source code
go

create procedure sys.sp_MSscriptcustomdelproc(@artid int, @publishertype tinyint, @publisher sysname, @usesqlclr bit,
                                              @inDDLrepl bit) as
-- missing source code
go

create procedure sys.sp_MSscriptcustominsproc(@artid int, @publishertype tinyint, @publisher sysname, @usesqlclr bit,
                                              @inDDLrepl bit) as
-- missing source code
go

create procedure sys.sp_MSscriptcustomupdproc(@artid int, @publishertype tinyint, @publisher sysname, @usesqlclr bit,
                                              @inDDLrepl bit) as
-- missing source code
go

create procedure sys.sp_MSscriptdatabase(@dbname nvarchar(258)) as
-- missing source code
go

create procedure sys.sp_MSscriptdb_worker() as
-- missing source code
go

create procedure sys.sp_MSscriptforeignkeyrestore(@program_name sysname, @constraint_name sysname,
                                                  @parent_schema sysname, @parent_name sysname,
                                                  @referenced_object_schema sysname, @referenced_object_name sysname,
                                                  @is_not_for_replication bit, @is_not_trusted bit,
                                                  @delete_referential_action tinyint,
                                                  @update_referential_action tinyint) as
-- missing source code
go

create procedure sys.sp_MSscriptsubscriberprocs(@publication sysname, @article sysname) as
-- missing source code
go

create procedure sys.sp_MSscriptviewproc(@viewname sysname, @ownername sysname, @procname sysname, @rgcol sysname,
                                         @pubid uniqueidentifier, @artid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSsendtosqlqueue(@objid int, @publisher sysname, @publisher_db sysname, @publication sysname,
                                         @owner sysname, @tranid sysname, @data varbinary(8000), @datalen int,
                                         @commandtype int, @cmdstate bit) as
-- missing source code
go

create procedure sys.sp_MSset_dynamic_filter_options(@publication sysname, @dynamic_filters bit, @dont_raise_error bit) as
-- missing source code
go

create procedure sys.sp_MSset_logicalrecord_metadata(@parent_nickname int, @parent_rowguid uniqueidentifier,
                                                     @logical_record_lineage varbinary(311)) as
-- missing source code
go

create procedure sys.sp_MSset_new_identity_range(@subid uniqueidentifier, @artid uniqueidentifier, @range_type tinyint,
                                                 @ranges_given tinyint, @range_begin numeric(38),
                                                 @range_end numeric(38), @next_range_begin numeric(38),
                                                 @next_range_end numeric(38)) as
-- missing source code
go

create procedure sys.sp_MSset_oledb_prop(@provider_name sysname, @property_name sysname, @property_value bit) as
-- missing source code
go

create procedure sys.sp_MSset_repl_serveroptions(@servername sysname, @dataaccess bit) as
-- missing source code
go

create procedure sys.sp_MSset_snapshot_xact_seqno(@publisher_id int, @publisher_db sysname, @article_id int,
                                                  @xact_seqno varbinary(16), @reset bit, @publication sysname,
                                                  @publisher_seqno varbinary(16), @ss_cplt_seqno varbinary(16)) as
-- missing source code
go

create procedure sys.sp_MSset_sub_guid(@publisher sysname, @publisher_db sysname, @publication sysname,
                                       @subscription_type int, @subscription_guid binary(16), @queue_id sysname,
                                       @queue_server sysname) as
-- missing source code
go

create procedure sys.sp_MSset_subscription_properties(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                      @subscription_type int, @allow_subscription_copy bit,
                                                      @queue_id sysname, @update_mode int, @attach_version binary(16),
                                                      @queue_server sysname) as
-- missing source code
go

create procedure sys.sp_MSsetaccesslist(@publication sysname, @publisher sysname, @publisher_db sysname) as
-- missing source code
go

create procedure sys.sp_MSsetalertinfo(@failsafeoperator nvarchar(255), @notificationmethod int,
                                       @forwardingserver nvarchar(255), @forwardingseverity int,
                                       @pagertotemplate nvarchar(255), @pagercctemplate nvarchar(255),
                                       @pagersubjecttemplate nvarchar(255), @pagersendsubjectonly int,
                                       @failsafeemailaddress nvarchar(255), @failsafepageraddress nvarchar(255),
                                       @failsafenetsendaddress nvarchar(255), @forwardalways int) as
-- missing source code
go

create procedure sys.sp_MSsetartprocs(@publication sysname, @article sysname, @force_flag int,
                                      @pubid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSsetbit(@bm varbinary(128), @coltoadd smallint, @toset int) as
-- missing source code
go

create procedure sys.sp_MSsetconflictscript(@publication sysname, @article sysname, @conflict_script nvarchar(255),
                                            @login sysname, @password nvarchar(524)) as
-- missing source code
go

create procedure sys.sp_MSsetconflicttable(@article sysname, @conflict_table sysname, @publisher sysname,
                                           @publisher_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_MSsetcontext_bypasswholeddleventbit(@onoff bit) as
-- missing source code
go

create procedure sys.sp_MSsetcontext_replagent(@agent_type tinyint, @is_publisher bit) as
-- missing source code
go

create procedure sys.sp_MSsetgentozero(@tablenick int, @rowguid uniqueidentifier, @metatype tinyint) as
-- missing source code
go

create procedure sys.sp_MSsetlastrecgen(@repid uniqueidentifier, @srcgen bigint, @srcguid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSsetlastsentgen(@repid uniqueidentifier, @srcgen bigint, @srcguid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSsetreplicainfo(@publisher sysname, @publisher_db sysname, @publication sysname,
                                         @datasource_type int, @server_name sysname, @db_name sysname,
                                         @datasource_path nvarchar(255), @replnick varbinary(6), @schemaversion int,
                                         @subid uniqueidentifier, @compatlevel int, @partition_id int,
                                         @replica_version int, @activate_subscription bit) as
-- missing source code
go

create procedure sys.sp_MSsetreplicaschemaversion(@subid uniqueidentifier, @schemaversion int,
                                                  @schemaguid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSsetreplicastatus(@subid uniqueidentifier, @status_value int) as
-- missing source code
go

create procedure sys.sp_MSsetrowmetadata(@tablenick int, @rowguid uniqueidentifier, @generation bigint,
                                         @lineage varbinary(311), @colv varbinary(2953), @type tinyint,
                                         @was_tombstone int, @compatlevel int, @isinsert bit, @pubid uniqueidentifier,
                                         @publication_number smallint, @partition_id int, @partition_options tinyint) as
-- missing source code
go

create procedure sys.sp_MSsetsubscriberinfo(@pubid uniqueidentifier, @expr nvarchar(500)) as
-- missing source code
go

create procedure sys.sp_MSsettopology(@server nvarchar(258), @X int, @Y int) as
-- missing source code
go

create procedure sys.sp_MSsetup_identity_range(@pubid uniqueidentifier, @artid uniqueidentifier, @range_type tinyint,
                                               @ranges_needed tinyint, @range_begin numeric(38), @range_end numeric(38),
                                               @next_range_begin numeric(38), @next_range_end numeric(38)) as
-- missing source code
go

create procedure sys.sp_MSsetup_partition_groups(@publication sysname) as
-- missing source code
go

create procedure sys.sp_MSsetup_use_partition_groups(@publication sysname) as
-- missing source code
go

create procedure sys.sp_MSsetupbelongs(@publisher sysname, @publisher_db sysname, @publication sysname,
                                       @genlist varchar(8000), @commongen bigint, @subissql int, @articlesoption int,
                                       @tablenickname int, @handle_null_tables bit, @nicknamelist varchar(8000),
                                       @mingen bigint, @maxgen bigint, @skipgenlist varchar(8000), @belongsname sysname,
                                       @notbelongsname sysname, @compatlevel int, @enumentirerowmetadata bit) as
-- missing source code
go

create procedure sys.sp_MSsetupnosyncsubwithlsnatdist(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                      @article sysname, @subscriber sysname, @destination_db sysname,
                                                      @subscriptionlsn binary(10), @lsnsource tinyint,
                                                      @originator_publication_id int, @originator_db_version int,
                                                      @originator_meta_data nvarchar(max),
                                                      @nosync_setup_script nvarchar(max), @next_valid_lsn binary(10)) as
-- missing source code
go

create procedure sys.sp_MSsetupnosyncsubwithlsnatdist_cleanup(@publisher sysname, @publisher_db sysname,
                                                              @publication sysname, @article sysname, @artid int,
                                                              @subscriber sysname, @destination_db sysname,
                                                              @next_valid_lsn binary(10)) as
-- missing source code
go

create procedure sys.sp_MSsetupnosyncsubwithlsnatdist_helper(@publisher sysname, @publisher_db sysname,
                                                             @publication sysname, @article sysname,
                                                             @subscriber sysname, @destination_db sysname,
                                                             @subscriptionlsn binary(10), @lsnsource int, @pubid int,
                                                             @publisher_db_version int, @script_txt nvarchar(max),
                                                             @nosync_setup_script nvarchar(max),
                                                             @next_valid_lsn binary(10), @artid int) as
-- missing source code
go

create procedure sys.sp_MSstartdistribution_agent(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                  @subscriber sysname, @subscriber_db sysname) as
-- missing source code
go

create procedure sys.sp_MSstartmerge_agent(@publisher sysname, @publisher_db sysname, @publication sysname,
                                           @subscriber sysname, @subscriber_db sysname) as
-- missing source code
go

create procedure sys.sp_MSstartsnapshot_agent(@publisher sysname, @publisher_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_MSstopdistribution_agent(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                 @subscriber sysname, @subscriber_db sysname) as
-- missing source code
go

create procedure sys.sp_MSstopmerge_agent(@publisher sysname, @publisher_db sysname, @publication sysname,
                                          @subscriber sysname, @subscriber_db sysname) as
-- missing source code
go

create procedure sys.sp_MSstopsnapshot_agent(@publisher sysname, @publisher_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_MSsub_check_identity(@lower_bound_id int) as
-- missing source code
go

create procedure sys.sp_MSsub_set_identity(@objid int, @threshold int, @range bigint, @next_seed bigint) as
-- missing source code
go

create procedure sys.sp_MSsubscription_status(@agent_id int) as
-- missing source code
go

create procedure sys.sp_MSsubscriptionvalidated(@subid uniqueidentifier, @pubid uniqueidentifier, @log_attempt bit) as
-- missing source code
go

create procedure sys.sp_MStablechecks(@tablename nvarchar(517), @flags int) as
-- missing source code
go

create procedure sys.sp_MStablekeys(@tablename nvarchar(776), @colname nvarchar(258), @type int, @keyname nvarchar(517),
                                    @flags int) as
-- missing source code
go

create procedure sys.sp_MStablerefs(@tablename nvarchar(517), @type nvarchar(20), @direction nvarchar(20),
                                    @reftable nvarchar(517), @flags int) as
-- missing source code
go

create procedure sys.sp_MStablespace(@name nvarchar(517), @id int) as
-- missing source code
go

create procedure sys.sp_MStestbit(@bm varbinary(128), @coltotest smallint) as
-- missing source code
go

create procedure sys.sp_MStran_ddlrepl(@EventData xml, @procmapid int) as
-- missing source code
go

create procedure sys.sp_MStran_is_snapshot_required(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                    @subscriber sysname, @subscriber_db sysname, @subscription_type int,
                                                    @run_at_distributor bit, @last_xact_seqno varbinary(16),
                                                    @subscription_guid varbinary(16), @subid varbinary(16)) as
-- missing source code
go

create procedure sys.sp_MStrypurgingoldsnapshotdeliveryprogress() as
-- missing source code
go

create procedure sys.sp_MSuniquename(@seed nvarchar(128), @start int) as
-- missing source code
go

create procedure sys.sp_MSunmarkifneeded(@object sysname, @pubid uniqueidentifier, @pre_command int, @publisher sysname,
                                         @publisher_db sysname) as
-- missing source code
go

create procedure sys.sp_MSunmarkreplinfo(@object sysname, @owner sysname, @type smallint) as
-- missing source code
go

create procedure sys.sp_MSunmarkschemaobject(@object sysname, @owner sysname) as
-- missing source code
go

create procedure sys.sp_MSunregistersubscription(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                 @subscriber sysname, @subscriber_db sysname) as
-- missing source code
go

create procedure sys.sp_MSupdate_agenttype_default(@profile_id int) as
-- missing source code
go

create procedure sys.sp_MSupdate_singlelogicalrecordmetadata(@logical_record_parent_nickname int,
                                                             @logical_record_parent_rowguid uniqueidentifier,
                                                             @replnick binary(6), @parent_row_inserted bit) as
-- missing source code
go

create procedure sys.sp_MSupdate_subscriber_info(@publisher sysname, @subscriber sysname, @type tinyint, @login sysname,
                                                 @password nvarchar(524), @commit_batch_size int,
                                                 @status_batch_size int, @flush_frequency int, @frequency_type int,
                                                 @frequency_interval int, @frequency_relative_interval int,
                                                 @frequency_recurrence_factor int, @frequency_subday int,
                                                 @frequency_subday_interval int, @active_start_time_of_day int,
                                                 @active_end_time_of_day int, @active_start_date int,
                                                 @active_end_date int, @retryattempts int, @retrydelay int,
                                                 @description nvarchar(255), @security_mode int) as
-- missing source code
go

create procedure sys.sp_MSupdate_subscriber_schedule(@publisher sysname, @subscriber sysname, @agent_type tinyint,
                                                     @frequency_type int, @frequency_interval int,
                                                     @frequency_relative_interval int, @frequency_recurrence_factor int,
                                                     @frequency_subday int, @frequency_subday_interval int,
                                                     @active_start_time_of_day int, @active_end_time_of_day int,
                                                     @active_start_date int, @active_end_date int) as
-- missing source code
go

create procedure sys.sp_MSupdate_subscriber_tracer_history(@parent_tracer_id int, @agent_id int) as
-- missing source code
go

create procedure sys.sp_MSupdate_subscription(@publisher sysname, @publisher_db sysname, @subscriber sysname,
                                              @article_id int, @status int, @subscription_seqno varbinary(16),
                                              @destination_db sysname) as
-- missing source code
go

create procedure sys.sp_MSupdate_tracer_history(@tracer_id int) as
-- missing source code
go

create procedure sys.sp_MSupdatecachedpeerlsn(@type int, @agent_id int, @originator sysname, @originator_db sysname,
                                              @originator_publication_id int, @originator_db_version int,
                                              @originator_lsn varbinary(16)) as
-- missing source code
go

create procedure sys.sp_MSupdategenerations_afterbcp(@pubid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSupdategenhistory(@guidsrc uniqueidentifier, @pubid uniqueidentifier, @gen bigint,
                                           @art_nick int, @is_ssce_empty_sync int, @publication_number smallint,
                                           @partition_id int) as
-- missing source code
go

create procedure sys.sp_MSupdateinitiallightweightsubscription(@publisher sysname, @publisher_db sysname,
                                                               @publication_name sysname, @pubid uniqueidentifier,
                                                               @allow_subscription_copy bit, @retention int,
                                                               @conflict_logging int, @status int,
                                                               @allow_synctoalternate bit, @replicate_ddl int,
                                                               @automatic_reinitialization_policy bit) as
-- missing source code
go

create procedure sys.sp_MSupdatelastsyncinfo(@publisher sysname, @publisher_db sysname, @publication sysname,
                                             @subscription_type int, @last_sync_status int,
                                             @last_sync_summary sysname) as
-- missing source code
go

create procedure sys.sp_MSupdatepeerlsn(@originator sysname, @originator_db sysname, @originator_publication_id int,
                                        @originator_db_version int, @originator_lsn varbinary(10)) as
-- missing source code
go

create procedure sys.sp_MSupdaterecgen(@altrepid uniqueidentifier, @altrecguid uniqueidentifier, @altrecgen bigint) as
-- missing source code
go

create procedure sys.sp_MSupdatereplicastate(@pubid uniqueidentifier, @subid uniqueidentifier,
                                             @replicastate uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_MSupdatesysmergearticles(@object sysname, @artid uniqueidentifier, @owner sysname,
                                                 @pubid uniqueidentifier, @recreate_repl_view bit) as
-- missing source code
go

create procedure sys.sp_MSuplineageversion(@tablenick int, @rowguid uniqueidentifier, @version int) as
-- missing source code
go

create procedure sys.sp_MSuploadsupportabilitydata(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                   @server_name sysname, @db_name sysname, @file_name nvarchar(2000),
                                                   @log_file_type int, @log_file varbinary(max), @web_server sysname,
                                                   @compatlevel int) as
-- missing source code
go

create procedure sys.sp_MSuselightweightreplication(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                    @lightweight int) as
-- missing source code
go

create procedure sys.sp_MSvalidate_dest_recgen(@pubid uniqueidentifier, @recguid uniqueidentifier, @recgen bigint) as
-- missing source code
go

create procedure sys.sp_MSvalidate_subscription(@subscriber sysname, @subscriber_db sysname, @artid int) as
-- missing source code
go

create procedure sys.sp_MSvalidate_wellpartitioned_articles(@publication sysname) as
-- missing source code
go

create procedure sys.sp_MSvalidatearticle(@artid uniqueidentifier, @pubid uniqueidentifier, @expected_rowcount bigint,
                                          @expected_checksum numeric, @validation_type int, @full_or_fast tinyint) as
-- missing source code
go

create procedure sys.sp_MSwritemergeperfcounter(@agent_id int, @thread_num int, @counter_desc nvarchar(100),
                                                @counter_value int) as
-- missing source code
go

create procedure sys.sp_OACreate() as
-- missing source code
go

create procedure sys.sp_OADestroy() as
-- missing source code
go

create procedure sys.sp_OAGetErrorInfo() as
-- missing source code
go

create procedure sys.sp_OAGetProperty() as
-- missing source code
go

create procedure sys.sp_OAMethod() as
-- missing source code
go

create procedure sys.sp_OASetProperty() as
-- missing source code
go

create procedure sys.sp_OAStop() as
-- missing source code
go

create procedure sys.sp_ORbitmap(@inputbitmap1 varbinary(128), @inputbitmap2 varbinary(128),
                                 @resultbitmap3 varbinary(128)) as
-- missing source code
go

create procedure sys.sp_PostAgentInfo() as
-- missing source code
go

create procedure sys.sp_SetAutoSAPasswordAndDisable() as
-- missing source code
go

create procedure sys.sp_SetOBDCertificate() as
-- missing source code
go

create procedure sys.sp_add_agent_parameter(@profile_id int, @parameter_name sysname, @parameter_value nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_add_agent_profile(@profile_id int, @profile_name sysname, @agent_type int, @profile_type int,
                                          @description nvarchar(3000), @default bit) as
-- missing source code
go

create procedure sys.sp_add_columnstore_column_dictionary(@table_id int, @column_id int) as
-- missing source code
go

create procedure sys.sp_add_data_file_recover_suspect_db(@dbName sysname, @filegroup nvarchar(260), @name nvarchar(260),
                                                         @filename nvarchar(260), @size nvarchar(20),
                                                         @maxsize nvarchar(20), @filegrowth nvarchar(20)) as
-- missing source code
go

create procedure sys.sp_add_log_file_recover_suspect_db(@dbName sysname, @name nvarchar(260), @filename nvarchar(260),
                                                        @size nvarchar(20), @maxsize nvarchar(20),
                                                        @filegrowth nvarchar(20)) as
-- missing source code
go

create procedure sys.sp_add_log_shipping_alert_job(@alert_job_id uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_add_log_shipping_primary_database(@database sysname, @backup_directory nvarchar(500),
                                                          @backup_share nvarchar(500), @backup_job_name sysname,
                                                          @backup_retention_period int, @monitor_server sysname,
                                                          @monitor_server_security_mode bit,
                                                          @monitor_server_login sysname,
                                                          @monitor_server_password sysname, @backup_threshold int,
                                                          @threshold_alert int, @threshold_alert_enabled bit,
                                                          @history_retention_period int,
                                                          @backup_job_id uniqueidentifier, @primary_id uniqueidentifier,
                                                          @overwrite bit, @ignoreremotemonitor bit,
                                                          @backup_compression tinyint,
                                                          @primary_server_with_port_override sysname) as
-- missing source code
go

create procedure sys.sp_add_log_shipping_primary_secondary(@primary_database sysname, @secondary_server sysname,
                                                           @secondary_database sysname, @overwrite bit) as
-- missing source code
go

create procedure sys.sp_add_log_shipping_secondary_database(@secondary_database sysname, @primary_server sysname,
                                                            @primary_database sysname, @restore_delay int,
                                                            @restore_all bit, @restore_mode bit, @disconnect_users bit,
                                                            @block_size int, @buffer_count int, @max_transfer_size int,
                                                            @restore_threshold int, @threshold_alert int,
                                                            @threshold_alert_enabled bit, @history_retention_period int,
                                                            @overwrite bit, @ignoreremotemonitor bit) as
-- missing source code
go

create procedure sys.sp_add_log_shipping_secondary_primary(@primary_server sysname, @primary_database sysname,
                                                           @backup_source_directory nvarchar(500),
                                                           @backup_destination_directory nvarchar(500),
                                                           @copy_job_name sysname, @restore_job_name sysname,
                                                           @file_retention_period int, @monitor_server sysname,
                                                           @monitor_server_security_mode bit,
                                                           @monitor_server_login sysname,
                                                           @monitor_server_password sysname,
                                                           @copy_job_id uniqueidentifier,
                                                           @restore_job_id uniqueidentifier,
                                                           @secondary_id uniqueidentifier, @overwrite bit,
                                                           @ignoreremotemonitor bit) as
-- missing source code
go

create procedure sys.sp_add_trusted_assembly() as
-- missing source code
go

create procedure sys.sp_addapprole(@rolename sysname, @password sysname) as
-- missing source code
go

create procedure sys.sp_addarticle(@publication sysname, @article sysname, @source_table nvarchar(386),
                                   @destination_table sysname, @vertical_partition nchar(5), @type sysname,
                                   @filter nvarchar(386), @sync_object nvarchar(386), @ins_cmd nvarchar(255),
                                   @del_cmd nvarchar(255), @upd_cmd nvarchar(255), @creation_script nvarchar(255),
                                   @description nvarchar(255), @pre_creation_cmd nvarchar(10),
                                   @filter_clause nvarchar(max), @schema_option varbinary(8),
                                   @destination_owner sysname, @status tinyint, @source_owner sysname,
                                   @sync_object_owner sysname, @filter_owner sysname, @source_object sysname,
                                   @artid int, @auto_identity_range nvarchar(5), @pub_identity_range bigint,
                                   @identity_range bigint, @threshold int, @force_invalidate_snapshot bit,
                                   @use_default_datatypes bit, @identityrangemanagementoption nvarchar(10),
                                   @publisher sysname, @fire_triggers_on_snapshot nvarchar(5)) as
-- missing source code
go

create procedure sys.sp_adddatatype(@dbms sysname, @version sysname, @type sysname, @createparams int) as
-- missing source code
go

create procedure sys.sp_adddatatypemapping(@source_dbms sysname, @source_version varchar(10), @source_type sysname,
                                           @source_length_min bigint, @source_length_max bigint,
                                           @source_precision_min bigint, @source_precision_max bigint,
                                           @source_scale_min int, @source_scale_max int, @source_nullable bit,
                                           @destination_dbms sysname, @destination_version varchar(10),
                                           @destination_type sysname, @destination_length bigint,
                                           @destination_precision bigint, @destination_scale int,
                                           @destination_nullable bit, @destination_createparams int, @dataloss bit,
                                           @is_default bit) as
-- missing source code
go

create procedure sys.sp_adddistpublisher(@publisher sysname, @distribution_db sysname, @security_mode int,
                                         @login sysname, @password sysname, @working_directory nvarchar(255),
                                         @trusted nvarchar(5), @encrypted_password bit, @thirdparty_flag bit,
                                         @publisher_type sysname, @storage_connection_string nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_adddistributiondb(@database sysname, @data_folder nvarchar(255), @data_file nvarchar(255),
                                          @data_file_size int, @log_folder nvarchar(255), @log_file nvarchar(255),
                                          @log_file_size int, @min_distretention int, @max_distretention int,
                                          @history_retention int, @security_mode int, @login sysname, @password sysname,
                                          @createmode int, @from_scripting bit, @deletebatchsize_xact int,
                                          @deletebatchsize_cmd int) as
-- missing source code
go

create procedure sys.sp_adddistributor(@distributor sysname, @heartbeat_interval int, @password sysname,
                                       @from_scripting bit) as
-- missing source code
go

create procedure sys.sp_adddynamicsnapshot_job(@publication sysname, @suser_sname sysname, @host_name sysname,
                                               @dynamic_snapshot_jobname sysname,
                                               @dynamic_snapshot_jobid uniqueidentifier, @frequency_type int,
                                               @frequency_interval int, @frequency_subday int,
                                               @frequency_subday_interval int, @frequency_relative_interval int,
                                               @frequency_recurrence_factor int, @active_start_date int,
                                               @active_end_date int, @active_start_time_of_day int,
                                               @active_end_time_of_day int) as
-- missing source code
go

create procedure sys.sp_addextendedproc(@functname nvarchar(517), @dllname varchar(255)) as
-- missing source code
go

create procedure sys.sp_addextendedproperty(@name sysname, @value sql_variant, @level0type varchar(128),
                                            @level0name sysname, @level1type varchar(128), @level1name sysname,
                                            @level2type varchar(128), @level2name sysname) as
-- missing source code
go

create procedure sys.sp_addlinkedserver(@server sysname, @srvproduct nvarchar(128), @provider nvarchar(128),
                                        @datasrc nvarchar(4000), @location nvarchar(4000), @provstr nvarchar(4000),
                                        @catalog sysname, @linkedstyle bit) as
-- missing source code
go

create procedure sys.sp_addlinkedsrvlogin(@rmtsrvname sysname, @useself varchar(8), @locallogin sysname,
                                          @rmtuser sysname, @rmtpassword sysname) as
-- missing source code
go

create procedure sys.sp_addlogin(@loginame sysname, @passwd sysname, @defdb sysname, @deflanguage sysname,
                                 @sid varbinary(16), @encryptopt varchar(20)) as
-- missing source code
go

create procedure sys.sp_addlogreader_agent(@job_login nvarchar(257), @job_password sysname, @job_name sysname,
                                           @publisher_security_mode smallint, @publisher_login sysname,
                                           @publisher_password sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_addmergealternatepublisher(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                   @alternate_publisher sysname, @alternate_publisher_db sysname,
                                                   @alternate_publication sysname, @alternate_distributor sysname,
                                                   @friendly_name nvarchar(255), @reserved nvarchar(20)) as
-- missing source code
go

create procedure sys.sp_addmergearticle(@publication sysname, @article sysname, @source_object sysname, @type sysname,
                                        @description nvarchar(255), @column_tracking nvarchar(10), @status nvarchar(10),
                                        @pre_creation_cmd nvarchar(10), @creation_script nvarchar(255),
                                        @schema_option varbinary(8), @subset_filterclause nvarchar(1000),
                                        @article_resolver nvarchar(255), @resolver_info nvarchar(517),
                                        @source_owner sysname, @destination_owner sysname,
                                        @vertical_partition nvarchar(5), @auto_identity_range nvarchar(5),
                                        @pub_identity_range bigint, @identity_range bigint, @threshold int,
                                        @verify_resolver_signature int, @destination_object sysname,
                                        @allow_interactive_resolver nvarchar(5), @fast_multicol_updateproc nvarchar(5),
                                        @check_permissions int, @force_invalidate_snapshot bit,
                                        @published_in_tran_pub nvarchar(5), @force_reinit_subscription bit,
                                        @logical_record_level_conflict_detection nvarchar(5),
                                        @logical_record_level_conflict_resolution nvarchar(5),
                                        @partition_options tinyint, @processing_order int,
                                        @subscriber_upload_options tinyint, @identityrangemanagementoption nvarchar(10),
                                        @delete_tracking nvarchar(5), @compensate_for_errors nvarchar(5),
                                        @stream_blob_columns nvarchar(5)) as
-- missing source code
go

create procedure sys.sp_addmergefilter(@publication sysname, @article sysname, @filtername sysname,
                                       @join_articlename sysname, @join_filterclause nvarchar(1000),
                                       @join_unique_key int, @force_invalidate_snapshot bit,
                                       @force_reinit_subscription bit, @filter_type tinyint) as
-- missing source code
go

create procedure sys.sp_addmergelogsettings(@publication sysname, @subscriber sysname, @subscriber_db sysname,
                                            @support_options int, @web_server sysname, @log_severity int,
                                            @log_modules int, @log_file_path nvarchar(255), @log_file_name sysname,
                                            @log_file_size int, @no_of_log_files int, @upload_interval int,
                                            @delete_after_upload int, @custom_script nvarchar(2000),
                                            @message_pattern nvarchar(2000), @agent_xe varbinary(max),
                                            @agent_xe_ring_buffer varbinary(max), @sql_xe varbinary(max)) as
-- missing source code
go

create procedure sys.sp_addmergepartition(@publication sysname, @suser_sname sysname, @host_name sysname) as
-- missing source code
go

create procedure sys.sp_addmergepublication(@publication sysname, @description nvarchar(255), @retention int,
                                            @sync_mode nvarchar(10), @allow_push nvarchar(5), @allow_pull nvarchar(5),
                                            @allow_anonymous nvarchar(5), @enabled_for_internet nvarchar(5),
                                            @centralized_conflicts nvarchar(5), @dynamic_filters nvarchar(5),
                                            @snapshot_in_defaultfolder nvarchar(5), @alt_snapshot_folder nvarchar(255),
                                            @pre_snapshot_script nvarchar(255), @post_snapshot_script nvarchar(255),
                                            @compress_snapshot nvarchar(5), @ftp_address sysname, @ftp_port int,
                                            @ftp_subdirectory nvarchar(255), @ftp_login sysname, @ftp_password sysname,
                                            @conflict_retention int, @keep_partition_changes nvarchar(5),
                                            @allow_subscription_copy nvarchar(5), @allow_synctoalternate nvarchar(5),
                                            @validate_subscriber_info nvarchar(500),
                                            @add_to_active_directory nvarchar(5), @max_concurrent_merge int,
                                            @max_concurrent_dynamic_snapshots int, @use_partition_groups nvarchar(5),
                                            @publication_compatibility_level nvarchar(6), @replicate_ddl int,
                                            @allow_subscriber_initiated_snapshot nvarchar(5),
                                            @allow_web_synchronization nvarchar(5),
                                            @web_synchronization_url nvarchar(500),
                                            @allow_partition_realignment nvarchar(5),
                                            @retention_period_unit nvarchar(10), @generation_leveling_threshold int,
                                            @automatic_reinitialization_policy bit, @conflict_logging nvarchar(15)) as
-- missing source code
go

create procedure sys.sp_addmergepullsubscription(@publication sysname, @publisher sysname, @publisher_db sysname,
                                                 @subscriber_type nvarchar(15), @subscription_priority real,
                                                 @sync_type nvarchar(15), @description nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_addmergepullsubscription_agent(@name sysname, @publisher sysname, @publisher_db sysname,
                                                       @publication sysname, @publisher_security_mode int,
                                                       @publisher_login sysname, @publisher_password sysname,
                                                       @publisher_encrypted_password bit, @subscriber sysname,
                                                       @subscriber_db sysname, @subscriber_security_mode int,
                                                       @subscriber_login sysname, @subscriber_password sysname,
                                                       @distributor sysname, @distributor_security_mode int,
                                                       @distributor_login sysname, @distributor_password sysname,
                                                       @encrypted_password bit, @frequency_type int,
                                                       @frequency_interval int, @frequency_relative_interval int,
                                                       @frequency_recurrence_factor int, @frequency_subday int,
                                                       @frequency_subday_interval int, @active_start_time_of_day int,
                                                       @active_end_time_of_day int, @active_start_date int,
                                                       @active_end_date int, @optional_command_line nvarchar(255),
                                                       @merge_jobid binary(16), @enabled_for_syncmgr nvarchar(5),
                                                       @ftp_address sysname, @ftp_port int, @ftp_login sysname,
                                                       @ftp_password sysname, @alt_snapshot_folder nvarchar(255),
                                                       @working_directory nvarchar(255), @use_ftp nvarchar(5),
                                                       @reserved nvarchar(100), @use_interactive_resolver nvarchar(5),
                                                       @offloadagent nvarchar(5), @offloadserver sysname,
                                                       @job_name sysname, @dynamic_snapshot_location nvarchar(260),
                                                       @use_web_sync bit, @internet_url nvarchar(260),
                                                       @internet_login sysname, @internet_password nvarchar(524),
                                                       @internet_security_mode int, @internet_timeout int,
                                                       @hostname sysname, @job_login nvarchar(257),
                                                       @job_password sysname) as
-- missing source code
go

create procedure sys.sp_addmergepushsubscription_agent(@publication sysname, @subscriber sysname,
                                                       @subscriber_db sysname, @subscriber_security_mode smallint,
                                                       @subscriber_login sysname, @subscriber_password sysname,
                                                       @publisher_security_mode smallint, @publisher_login sysname,
                                                       @publisher_password sysname, @job_login nvarchar(257),
                                                       @job_password sysname, @job_name sysname, @frequency_type int,
                                                       @frequency_interval int, @frequency_relative_interval int,
                                                       @frequency_recurrence_factor int, @frequency_subday int,
                                                       @frequency_subday_interval int, @active_start_time_of_day int,
                                                       @active_end_time_of_day int, @active_start_date int,
                                                       @active_end_date int, @enabled_for_syncmgr nvarchar(5)) as
-- missing source code
go

create procedure sys.sp_addmergesubscription(@publication sysname, @subscriber sysname, @subscriber_db sysname,
                                             @subscription_type nvarchar(15), @subscriber_type nvarchar(15),
                                             @subscription_priority real, @sync_type nvarchar(15), @frequency_type int,
                                             @frequency_interval int, @frequency_relative_interval int,
                                             @frequency_recurrence_factor int, @frequency_subday int,
                                             @frequency_subday_interval int, @active_start_time_of_day int,
                                             @active_end_time_of_day int, @active_start_date int, @active_end_date int,
                                             @optional_command_line nvarchar(4000), @description nvarchar(255),
                                             @enabled_for_syncmgr nvarchar(5), @offloadagent bit,
                                             @offloadserver sysname, @use_interactive_resolver nvarchar(5),
                                             @merge_job_name sysname, @hostname sysname) as
-- missing source code
go

create procedure sys.sp_addmessage(@msgnum int, @severity smallint, @msgtext nvarchar(255), @lang sysname,
                                   @with_log varchar(5), @replace varchar(7)) as
-- missing source code
go

create procedure sys.sp_addpublication(@publication sysname, @taskid int, @restricted nvarchar(10),
                                       @sync_method nvarchar(40), @repl_freq nvarchar(10), @description nvarchar(255),
                                       @status nvarchar(8), @independent_agent nvarchar(5), @immediate_sync nvarchar(5),
                                       @enabled_for_internet nvarchar(5), @allow_push nvarchar(5),
                                       @allow_pull nvarchar(5), @allow_anonymous nvarchar(5),
                                       @allow_sync_tran nvarchar(5), @autogen_sync_procs nvarchar(5), @retention int,
                                       @allow_queued_tran nvarchar(5), @snapshot_in_defaultfolder nvarchar(5),
                                       @alt_snapshot_folder nvarchar(255), @pre_snapshot_script nvarchar(255),
                                       @post_snapshot_script nvarchar(255), @compress_snapshot nvarchar(5),
                                       @ftp_address sysname, @ftp_port int, @ftp_subdirectory nvarchar(255),
                                       @ftp_login sysname, @ftp_password sysname, @allow_dts nvarchar(5),
                                       @allow_subscription_copy nvarchar(5), @conflict_policy nvarchar(100),
                                       @centralized_conflicts nvarchar(5), @conflict_retention int,
                                       @queue_type nvarchar(10), @add_to_active_directory nvarchar(10),
                                       @logreader_job_name sysname, @qreader_job_name sysname, @publisher sysname,
                                       @allow_initialize_from_backup nvarchar(5), @replicate_ddl int,
                                       @enabled_for_p2p nvarchar(5), @publish_local_changes_only nvarchar(5),
                                       @enabled_for_het_sub nvarchar(5), @p2p_conflictdetection nvarchar(5),
                                       @p2p_originator_id int, @p2p_continue_onconflict nvarchar(5),
                                       @allow_partition_switch nvarchar(5), @replicate_partition_switch nvarchar(5),
                                       @allow_drop nvarchar(5), @p2p_conflictdetection_policy nvarchar(12)) as
-- missing source code
go

create procedure sys.sp_addpublication_snapshot(@publication sysname, @frequency_type int, @frequency_interval int,
                                                @frequency_subday int, @frequency_subday_interval int,
                                                @frequency_relative_interval int, @frequency_recurrence_factor int,
                                                @active_start_date int, @active_end_date int,
                                                @active_start_time_of_day int, @active_end_time_of_day int,
                                                @snapshot_job_name nvarchar(100), @publisher_security_mode int,
                                                @publisher_login sysname, @publisher_password sysname,
                                                @job_login nvarchar(257), @job_password sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_addpullsubscription(@publisher sysname, @publisher_db sysname, @publication sysname,
                                            @independent_agent nvarchar(5), @subscription_type nvarchar(9),
                                            @description nvarchar(100), @update_mode nvarchar(30),
                                            @immediate_sync bit) as
-- missing source code
go

create procedure sys.sp_addpullsubscription_agent(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                  @subscriber sysname, @subscriber_db sysname,
                                                  @subscriber_security_mode int, @subscriber_login sysname,
                                                  @subscriber_password sysname, @distributor sysname,
                                                  @distribution_db sysname, @distributor_security_mode int,
                                                  @distributor_login sysname, @distributor_password sysname,
                                                  @optional_command_line nvarchar(4000), @frequency_type int,
                                                  @frequency_interval int, @frequency_relative_interval int,
                                                  @frequency_recurrence_factor int, @frequency_subday int,
                                                  @frequency_subday_interval int, @active_start_time_of_day int,
                                                  @active_end_time_of_day int, @active_start_date int,
                                                  @active_end_date int, @distribution_jobid binary(16),
                                                  @encrypted_distributor_password bit, @enabled_for_syncmgr nvarchar(5),
                                                  @ftp_address sysname, @ftp_port int, @ftp_login sysname,
                                                  @ftp_password sysname, @alt_snapshot_folder nvarchar(255),
                                                  @working_directory nvarchar(255), @use_ftp nvarchar(5),
                                                  @publication_type tinyint, @dts_package_name sysname,
                                                  @dts_package_password sysname, @dts_package_location nvarchar(12),
                                                  @reserved nvarchar(100), @offloadagent nvarchar(5),
                                                  @offloadserver sysname, @job_name sysname, @job_login nvarchar(257),
                                                  @job_password sysname) as
-- missing source code
go

create procedure sys.sp_addpushsubscription_agent(@publication sysname, @subscriber sysname, @subscriber_db sysname,
                                                  @subscriber_security_mode smallint, @subscriber_login sysname,
                                                  @subscriber_password sysname, @job_login nvarchar(257),
                                                  @job_password sysname, @job_name sysname, @frequency_type int,
                                                  @frequency_interval int, @frequency_relative_interval int,
                                                  @frequency_recurrence_factor int, @frequency_subday int,
                                                  @frequency_subday_interval int, @active_start_time_of_day int,
                                                  @active_end_time_of_day int, @active_start_date int,
                                                  @active_end_date int, @dts_package_name sysname,
                                                  @dts_package_password sysname, @dts_package_location nvarchar(12),
                                                  @enabled_for_syncmgr nvarchar(5), @distribution_job_name sysname,
                                                  @publisher sysname, @subscriber_provider sysname,
                                                  @subscriber_datasrc nvarchar(4000),
                                                  @subscriber_location nvarchar(4000),
                                                  @subscriber_provider_string nvarchar(4000),
                                                  @subscriber_catalog sysname) as
-- missing source code
go

create procedure sys.sp_addqreader_agent(@job_login nvarchar(257), @job_password sysname, @job_name sysname,
                                         @frompublisher bit) as
-- missing source code
go

create procedure sys.sp_addqueued_artinfo(@artid int, @article sysname, @publisher sysname, @publisher_db sysname,
                                          @publication sysname, @dest_table sysname, @owner sysname, @cft_table sysname,
                                          @columns binary(32)) as
-- missing source code
go

create procedure sys.sp_addremotelogin(@remoteserver sysname, @loginame sysname, @remotename sysname) as
-- missing source code
go

create procedure sys.sp_addrole(@rolename sysname, @ownername sysname) as
-- missing source code
go

create procedure sys.sp_addrolemember(@rolename sysname, @membername sysname) as
-- missing source code
go

create procedure sys.sp_addscriptexec(@publication sysname, @scriptfile nvarchar(4000), @skiperror bit,
                                      @publisher sysname) as
-- missing source code
go

create procedure sys.sp_addserver(@server sysname, @local varchar(10), @duplicate_ok varchar(13)) as
-- missing source code
go

create procedure sys.sp_addsrvrolemember(@loginame sysname, @rolename sysname) as
-- missing source code
go

create procedure sys.sp_addsubscriber(@subscriber sysname, @type tinyint, @login sysname, @password nvarchar(524),
                                      @commit_batch_size int, @status_batch_size int, @flush_frequency int,
                                      @frequency_type int, @frequency_interval int, @frequency_relative_interval int,
                                      @frequency_recurrence_factor int, @frequency_subday int,
                                      @frequency_subday_interval int, @active_start_time_of_day int,
                                      @active_end_time_of_day int, @active_start_date int, @active_end_date int,
                                      @description nvarchar(255), @security_mode int, @encrypted_password bit,
                                      @publisher sysname) as
-- missing source code
go

create procedure sys.sp_addsubscriber_schedule(@subscriber sysname, @agent_type smallint, @frequency_type int,
                                               @frequency_interval int, @frequency_relative_interval int,
                                               @frequency_recurrence_factor int, @frequency_subday int,
                                               @frequency_subday_interval int, @active_start_time_of_day int,
                                               @active_end_time_of_day int, @active_start_date int,
                                               @active_end_date int, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_addsubscription(@publication sysname, @article sysname, @subscriber sysname,
                                        @destination_db sysname, @sync_type nvarchar(255), @status sysname,
                                        @subscription_type nvarchar(4), @update_mode nvarchar(30),
                                        @loopback_detection nvarchar(5), @frequency_type int, @frequency_interval int,
                                        @frequency_relative_interval int, @frequency_recurrence_factor int,
                                        @frequency_subday int, @frequency_subday_interval int,
                                        @active_start_time_of_day int, @active_end_time_of_day int,
                                        @active_start_date int, @active_end_date int,
                                        @optional_command_line nvarchar(4000), @reserved nvarchar(10),
                                        @enabled_for_syncmgr nvarchar(5), @offloadagent bit, @offloadserver sysname,
                                        @dts_package_name sysname, @dts_package_password sysname,
                                        @dts_package_location nvarchar(12), @distribution_job_name sysname,
                                        @publisher sysname, @backupdevicetype nvarchar(20),
                                        @backupdevicename nvarchar(1000), @mediapassword sysname, @password sysname,
                                        @fileidhint int, @unload bit, @subscriptionlsn binary(10),
                                        @subscriptionstreams tinyint, @subscriber_type tinyint,
                                        @memory_optimized bit) as
-- missing source code
go

create procedure sys.sp_addsynctriggers(@sub_table sysname, @sub_table_owner sysname, @publisher sysname,
                                        @publisher_db sysname, @publication sysname, @ins_proc sysname,
                                        @upd_proc sysname, @del_proc sysname, @cftproc sysname, @proc_owner sysname,
                                        @identity_col sysname, @ts_col sysname, @filter_clause nvarchar(4000),
                                        @primary_key_bitmap varbinary(4000), @identity_support bit,
                                        @independent_agent bit, @distributor sysname, @pubversion int,
                                        @dump_cmds bit) as
-- missing source code
go

create procedure sys.sp_addsynctriggerscore(@sub_table sysname, @sub_table_owner sysname, @publisher sysname,
                                            @publisher_db sysname, @publication sysname, @ins_proc sysname,
                                            @upd_proc sysname, @del_proc sysname, @cftproc sysname, @proc_owner sysname,
                                            @identity_col sysname, @ts_col sysname, @filter_clause nvarchar(4000),
                                            @primary_key_bitmap varbinary(4000), @identity_support bit,
                                            @independent_agent bit, @pubversion int, @ins_trig sysname,
                                            @upd_trig sysname, @del_trig sysname, @alter bit, @dump_cmds bit) as
-- missing source code
go

create procedure sys.sp_addtabletocontents(@table_name sysname, @owner_name sysname, @filter_clause nvarchar(4000)) as
-- missing source code
go

create procedure sys.sp_addtype(@typename sysname, @phystype sysname, @nulltype varchar(8), @owner sysname) as
-- missing source code
go

create procedure sys.sp_addumpdevice(@devtype varchar(20), @logicalname sysname, @physicalname nvarchar(260),
                                     @cntrltype smallint, @devstatus varchar(40)) as
-- missing source code
go

create procedure sys.sp_adduser(@loginame sysname, @name_in_db sysname, @grpname sysname) as
-- missing source code
go

create procedure sys.sp_adjustpublisheridentityrange(@publication sysname, @table_name sysname, @table_owner sysname) as
-- missing source code
go

create procedure sys.sp_alter_nt_job_mem_configs() as
-- missing source code
go

create procedure sys.sp_altermessage(@message_id int, @parameter sysname, @parameter_value varchar(5)) as
-- missing source code
go

create procedure sys.sp_approlepassword(@rolename sysname, @newpwd sysname) as
-- missing source code
go

create procedure sys.sp_article_validation(@publication sysname, @article sysname, @rowcount_only smallint,
                                           @full_or_fast tinyint, @shutdown_agent bit, @subscription_level bit,
                                           @reserved int, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_articlecolumn(@publication sysname, @article sysname, @column sysname, @operation nvarchar(5),
                                      @refresh_synctran_procs bit, @ignore_distributor bit, @change_active int,
                                      @force_invalidate_snapshot bit, @force_reinit_subscription bit,
                                      @publisher sysname, @internal bit) as
-- missing source code
go

create procedure sys.sp_articlefilter(@publication sysname, @article sysname, @filter_name nvarchar(517),
                                      @filter_clause nvarchar(max), @force_invalidate_snapshot bit,
                                      @force_reinit_subscription bit, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_articleview(@publication sysname, @article sysname, @view_name nvarchar(386),
                                    @filter_clause nvarchar(max), @change_active int, @force_invalidate_snapshot bit,
                                    @force_reinit_subscription bit, @publisher sysname, @refreshsynctranprocs bit,
                                    @internal bit) as
-- missing source code
go

create procedure sys.sp_assemblies_rowset(@assembly_name sysname, @assembly_schema sysname, @assembly_id int) as
-- missing source code
go

create procedure sys.sp_assemblies_rowset2(@assembly_schema sysname, @assembly_id int) as
-- missing source code
go

create procedure sys.sp_assemblies_rowset_rmt(@server_name sysname, @catalog_name sysname, @assembly_name sysname,
                                              @assembly_schema sysname, @assembly_id int) as
-- missing source code
go

create procedure sys.sp_assembly_dependencies_rowset(@assembly_id int, @assembly_schema sysname, @assembly_referenced int) as
-- missing source code
go

create procedure sys.sp_assembly_dependencies_rowset2(@assembly_schema sysname, @assembly_referenced int) as
-- missing source code
go

create procedure sys.sp_assembly_dependencies_rowset_rmt(@server sysname, @catalog sysname, @assembly_id int,
                                                         @assembly_schema sysname, @assembly_referenced int) as
-- missing source code
go

create procedure sys.sp_attach_db(@dbname sysname, @filename1 nvarchar(260), @filename2 nvarchar(260),
                                  @filename3 nvarchar(260), @filename4 nvarchar(260), @filename5 nvarchar(260),
                                  @filename6 nvarchar(260), @filename7 nvarchar(260), @filename8 nvarchar(260),
                                  @filename9 nvarchar(260), @filename10 nvarchar(260), @filename11 nvarchar(260),
                                  @filename12 nvarchar(260), @filename13 nvarchar(260), @filename14 nvarchar(260),
                                  @filename15 nvarchar(260), @filename16 nvarchar(260)) as
-- missing source code
go

create procedure sys.sp_attach_single_file_db(@dbname sysname, @physname nvarchar(260)) as
-- missing source code
go

create procedure sys.sp_attachsubscription(@dbname sysname, @filename nvarchar(260), @subscriber_security_mode int,
                                           @subscriber_login sysname, @subscriber_password sysname,
                                           @distributor_security_mode int, @distributor_login sysname,
                                           @distributor_password sysname, @publisher_security_mode int,
                                           @publisher_login sysname, @publisher_password sysname,
                                           @job_login nvarchar(257), @job_password sysname,
                                           @db_master_key_password nvarchar(524)) as
-- missing source code
go

create procedure sys.sp_audit_write() as
-- missing source code
go

create procedure sys.sp_autoindex_cancel_dta() as
-- missing source code
go

create procedure sys.sp_autoindex_invoke_dta() as
-- missing source code
go

create procedure sys.sp_autostats(@tblname nvarchar(776), @flagc varchar(10), @indname sysname) as
-- missing source code
go

create procedure sys.sp_availability_group_command_internal() as
-- missing source code
go

create procedure sys.sp_bcp_dbcmptlevel(@dbname sysname) as
-- missing source code
go

create procedure sys.sp_begin_parallel_nested_tran() as
-- missing source code
go

create procedure sys.sp_bindefault(@defname nvarchar(776), @objname nvarchar(776), @futureonly varchar(15)) as
-- missing source code
go

create procedure sys.sp_bindrule(@rulename nvarchar(776), @objname nvarchar(776), @futureonly varchar(15)) as
-- missing source code
go

create procedure sys.sp_bindsession() as
-- missing source code
go

create procedure sys.sp_browsemergesnapshotfolder(@publication sysname) as
-- missing source code
go

create procedure sys.sp_browsereplcmds(@xact_seqno_start nchar(22), @xact_seqno_end nchar(22), @originator_id int,
                                       @publisher_database_id int, @article_id int, @command_id int, @agent_id int,
                                       @compatibility_level int) as
-- missing source code
go

create procedure sys.sp_browsesnapshotfolder(@publication sysname, @subscriber sysname, @subscriber_db sysname,
                                             @publisher sysname) as
-- missing source code
go

create procedure sys.sp_build_histogram() as
-- missing source code
go

create procedure sys.sp_can_tlog_be_applied(@backup_file_name nvarchar(500), @database_name sysname, @result bit,
                                            @verbose bit) as
-- missing source code
go

create procedure sys.sp_catalogs(@server_name sysname) as
-- missing source code
go

create procedure sys.sp_catalogs_rowset(@catalog_name sysname) as
-- missing source code
go

create procedure sys.sp_catalogs_rowset2() as
-- missing source code
go

create procedure sys.sp_catalogs_rowset_rmt(@server_name sysname, @catalog_name sysname) as
-- missing source code
go

create procedure sys.sp_cdc_add_job(@job_type nvarchar(20), @start_job bit, @maxtrans int, @maxscans int,
                                    @continuous bit, @pollinginterval bigint, @retention bigint, @threshold bigint,
                                    @check_for_logreader bit) as
-- missing source code
go

create procedure sys.sp_cdc_change_job(@job_type nvarchar(20), @maxtrans int, @maxscans int, @continuous bit,
                                       @pollinginterval bigint, @retention bigint, @threshold bigint) as
-- missing source code
go

create procedure sys.sp_cdc_cleanup_change_table(@capture_instance sysname, @low_water_mark binary(10),
                                                 @threshold bigint, @fCleanupFailed bit) as
-- missing source code
go

create procedure sys.sp_cdc_dbsnapshotLSN(@db_snapshot sysname, @lastLSN binary(10), @lastLSNstr varchar(40)) as
-- missing source code
go

create procedure sys.sp_cdc_disable_db() as
-- missing source code
go

create procedure sys.sp_cdc_disable_table(@source_schema sysname, @source_name sysname, @capture_instance sysname) as
-- missing source code
go

create procedure sys.sp_cdc_drop_job(@job_type nvarchar(20)) as
-- missing source code
go

create procedure sys.sp_cdc_enable_db(@fCreateCDCUserImplicit bit) as
-- missing source code
go

create procedure sys.sp_cdc_enable_table(@source_schema sysname, @source_name sysname, @capture_instance sysname,
                                         @supports_net_changes bit, @role_name sysname, @index_name sysname,
                                         @captured_column_list nvarchar(max), @filegroup_name sysname,
                                         @allow_partition_switch bit, @enable_extended_ddl_handling bit) as
-- missing source code
go

create procedure sys.sp_cdc_generate_wrapper_function(@capture_instance sysname, @closed_high_end_point bit,
                                                      @column_list nvarchar(max), @update_flag_list nvarchar(max)) as
-- missing source code
go

create procedure sys.sp_cdc_get_captured_columns(@capture_instance sysname) as
-- missing source code
go

create procedure sys.sp_cdc_get_ddl_history(@capture_instance sysname) as
-- missing source code
go

create procedure sys.sp_cdc_help_change_data_capture(@source_schema sysname, @source_name sysname) as
-- missing source code
go

create procedure sys.sp_cdc_help_jobs() as
-- missing source code
go

create procedure sys.sp_cdc_restoredb(@srv_orig sysname, @db_orig sysname, @keep_cdc int, @shouldStartCDCjobs int) as
-- missing source code
go

create procedure sys.sp_cdc_scan(@maxtrans int, @maxscans int, @continuous tinyint, @pollinginterval bigint,
                                 @is_from_job int) as
-- missing source code
go

create procedure sys.sp_cdc_set_scheduler_job() as
-- missing source code
go

create procedure sys.sp_cdc_start_job(@job_type nvarchar(20)) as
-- missing source code
go

create procedure sys.sp_cdc_stop_job(@job_type nvarchar(20)) as
-- missing source code
go

create procedure sys.sp_cdc_vupgrade() as
-- missing source code
go

create procedure sys.sp_cdc_vupgrade_databases(@db_id int) as
-- missing source code
go

create procedure sys.sp_certificate_add_issuer() as
-- missing source code
go

create procedure sys.sp_certificate_drop_issuer() as
-- missing source code
go

create procedure sys.sp_certificate_issuers() as
-- missing source code
go

create procedure sys.sp_certify_removable(@dbname sysname, @autofix nvarchar(4)) as
-- missing source code
go

create procedure sys.sp_change_agent_parameter(@profile_id int, @parameter_name sysname,
                                               @parameter_value nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_change_agent_profile(@profile_id int, @property sysname, @value nvarchar(3000)) as
-- missing source code
go

create procedure sys.sp_change_feed_configure_parameters(@maxtrans int, @pollinterval int) as
-- missing source code
go

create procedure sys.sp_change_feed_create_table_group(@table_group_id uniqueidentifier,
                                                       @table_group_name nvarchar(140), @workspace_id nvarchar(247),
                                                       @destination_location nvarchar(512),
                                                       @destination_credential sysname) as
-- missing source code
go

create procedure sys.sp_change_feed_disable_db() as
-- missing source code
go

create procedure sys.sp_change_feed_disable_table(@table_group_id uniqueidentifier, @table_id uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_change_feed_drop_table_group(@table_group_id uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_change_feed_enable_db(@maxtrans int, @pollinterval int) as
-- missing source code
go

create procedure sys.sp_change_feed_enable_table(@table_group_id uniqueidentifier, @table_id uniqueidentifier,
                                                 @source_schema sysname, @source_name sysname) as
-- missing source code
go

create procedure sys.sp_change_feed_vupgrade() as
-- missing source code
go

create procedure sys.sp_change_log_shipping_primary_database(@database sysname, @backup_directory nvarchar(500),
                                                             @backup_share nvarchar(500), @backup_retention_period int,
                                                             @monitor_server_security_mode bit,
                                                             @monitor_server_login sysname,
                                                             @monitor_server_password sysname, @backup_threshold int,
                                                             @threshold_alert int, @threshold_alert_enabled bit,
                                                             @history_retention_period int, @ignoreremotemonitor bit,
                                                             @backup_compression tinyint,
                                                             @primary_server_with_port_override sysname) as
-- missing source code
go

create procedure sys.sp_change_log_shipping_secondary_database(@secondary_database sysname, @restore_delay int,
                                                               @restore_all bit, @restore_mode bit,
                                                               @disconnect_users bit, @block_size int,
                                                               @buffer_count int, @max_transfer_size int,
                                                               @restore_threshold int, @threshold_alert int,
                                                               @threshold_alert_enabled bit,
                                                               @history_retention_period int,
                                                               @ignoreremotemonitor bit) as
-- missing source code
go

create procedure sys.sp_change_log_shipping_secondary_primary(@primary_server sysname, @primary_database sysname,
                                                              @backup_source_directory nvarchar(500),
                                                              @backup_destination_directory nvarchar(500),
                                                              @file_retention_period int,
                                                              @monitor_server_security_mode bit,
                                                              @monitor_server_login sysname,
                                                              @monitor_server_password sysname) as
-- missing source code
go

create procedure sys.sp_change_repl_serverport(@server sysname, @port int) as
-- missing source code
go

create procedure sys.sp_change_subscription_properties(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                       @property sysname, @value nvarchar(1000),
                                                       @publication_type int) as
-- missing source code
go

create procedure sys.sp_change_tracking_waitforchanges() as
-- missing source code
go

create procedure sys.sp_change_users_login(@Action varchar(10), @UserNamePattern sysname, @LoginName sysname,
                                           @Password sysname) as
-- missing source code
go

create procedure sys.sp_changearticle(@publication sysname, @article sysname, @property nvarchar(100),
                                      @value nvarchar(255), @force_invalidate_snapshot bit,
                                      @force_reinit_subscription bit, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_changearticlecolumndatatype(@publication sysname, @article sysname, @column sysname,
                                                    @mapping_id int, @type sysname, @length bigint, @precision bigint,
                                                    @scale bigint, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_changedbowner(@loginame sysname, @map varchar(5)) as
-- missing source code
go

create procedure sys.sp_changedistpublisher(@publisher sysname, @property sysname, @value nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_changedistributiondb(@database sysname, @property sysname, @value nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_changedistributor_password(@password sysname) as
-- missing source code
go

create procedure sys.sp_changedistributor_property(@property sysname, @value nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_changedynamicsnapshot_job(@publication sysname, @dynamic_snapshot_jobname sysname,
                                                  @dynamic_snapshot_jobid uniqueidentifier, @frequency_type int,
                                                  @frequency_interval int, @frequency_subday int,
                                                  @frequency_subday_interval int, @frequency_relative_interval int,
                                                  @frequency_recurrence_factor int, @active_start_date int,
                                                  @active_end_date int, @active_start_time_of_day int,
                                                  @active_end_time_of_day int, @job_login nvarchar(257),
                                                  @job_password sysname) as
-- missing source code
go

create procedure sys.sp_changelogreader_agent(@job_login nvarchar(257), @job_password sysname,
                                              @publisher_security_mode smallint, @publisher_login sysname,
                                              @publisher_password sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_changemergearticle(@publication sysname, @article sysname, @property sysname,
                                           @value nvarchar(2000), @force_invalidate_snapshot bit,
                                           @force_reinit_subscription bit) as
-- missing source code
go

create procedure sys.sp_changemergefilter(@publication sysname, @article sysname, @filtername sysname,
                                          @property sysname, @value nvarchar(1000), @force_invalidate_snapshot bit,
                                          @force_reinit_subscription bit) as
-- missing source code
go

create procedure sys.sp_changemergelogsettings(@publication sysname, @subscriber sysname, @subscriber_db sysname,
                                               @support_options int, @web_server sysname, @log_severity int,
                                               @log_modules int, @log_file_path nvarchar(255), @log_file_name sysname,
                                               @log_file_size int, @no_of_log_files int, @upload_interval int,
                                               @delete_after_upload int, @custom_script nvarchar(2000),
                                               @message_pattern nvarchar(2000), @agent_xe varbinary(max),
                                               @agent_xe_ring_buffer varbinary(max), @sql_xe varbinary(max)) as
-- missing source code
go

create procedure sys.sp_changemergepublication(@publication sysname, @property sysname, @value nvarchar(255),
                                               @force_invalidate_snapshot bit, @force_reinit_subscription bit) as
-- missing source code
go

create procedure sys.sp_changemergepullsubscription(@publication sysname, @publisher sysname, @publisher_db sysname,
                                                    @property sysname, @value nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_changemergesubscription(@publication sysname, @subscriber sysname, @subscriber_db sysname,
                                                @property sysname, @value nvarchar(255),
                                                @force_reinit_subscription bit) as
-- missing source code
go

create procedure sys.sp_changeobjectowner(@objname nvarchar(776), @newowner sysname) as
-- missing source code
go

create procedure sys.sp_changepublication(@publication sysname, @property nvarchar(255), @value nvarchar(255),
                                          @force_invalidate_snapshot bit, @force_reinit_subscription bit,
                                          @publisher sysname) as
-- missing source code
go

create procedure sys.sp_changepublication_snapshot(@publication sysname, @frequency_type int, @frequency_interval int,
                                                   @frequency_subday int, @frequency_subday_interval int,
                                                   @frequency_relative_interval int, @frequency_recurrence_factor int,
                                                   @active_start_date int, @active_end_date int,
                                                   @active_start_time_of_day int, @active_end_time_of_day int,
                                                   @snapshot_job_name nvarchar(100), @publisher_security_mode int,
                                                   @publisher_login sysname, @publisher_password sysname,
                                                   @job_login nvarchar(257), @job_password sysname,
                                                   @publisher sysname) as
-- missing source code
go

create procedure sys.sp_changeqreader_agent(@job_login nvarchar(257), @job_password sysname, @frompublisher bit) as
-- missing source code
go

create procedure sys.sp_changereplicationserverpasswords(@login_type tinyint, @login nvarchar(257), @password sysname,
                                                         @server sysname) as
-- missing source code
go

create procedure sys.sp_changesubscriber(@subscriber sysname, @type tinyint, @login sysname, @password sysname,
                                         @commit_batch_size int, @status_batch_size int, @flush_frequency int,
                                         @frequency_type int, @frequency_interval int, @frequency_relative_interval int,
                                         @frequency_recurrence_factor int, @frequency_subday int,
                                         @frequency_subday_interval int, @active_start_time_of_day int,
                                         @active_end_time_of_day int, @active_start_date int, @active_end_date int,
                                         @description nvarchar(255), @security_mode int, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_changesubscriber_schedule(@subscriber sysname, @agent_type smallint, @frequency_type int,
                                                  @frequency_interval int, @frequency_relative_interval int,
                                                  @frequency_recurrence_factor int, @frequency_subday int,
                                                  @frequency_subday_interval int, @active_start_time_of_day int,
                                                  @active_end_time_of_day int, @active_start_date int,
                                                  @active_end_date int, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_changesubscription(@publication sysname, @article sysname, @subscriber sysname,
                                           @destination_db sysname, @property nvarchar(30), @value nvarchar(4000),
                                           @publisher sysname) as
-- missing source code
go

create procedure sys.sp_changesubscriptiondtsinfo(@job_id varbinary(16), @dts_package_name sysname,
                                                  @dts_package_password sysname, @dts_package_location nvarchar(12)) as
-- missing source code
go

create procedure sys.sp_changesubstatus(@publication sysname, @article sysname, @subscriber sysname, @status sysname,
                                        @previous_status sysname, @destination_db sysname, @frequency_type int,
                                        @frequency_interval int, @frequency_relative_interval int,
                                        @frequency_recurrence_factor int, @frequency_subday int,
                                        @frequency_subday_interval int, @active_start_time_of_day int,
                                        @active_end_time_of_day int, @active_start_date int, @active_end_date int,
                                        @optional_command_line nvarchar(4000), @distribution_jobid binary(16),
                                        @from_auto_sync bit, @ignore_distributor bit, @offloadagent bit,
                                        @offloadserver sysname, @dts_package_name sysname,
                                        @dts_package_password nvarchar(524), @dts_package_location int,
                                        @skipobjectactivation int, @distribution_job_name sysname, @publisher sysname,
                                        @ignore_distributor_failure bit) as
-- missing source code
go

create procedure sys.sp_checkOraclepackageversion(@publisher sysname, @versionsmatch int,
                                                  @packageversion nvarchar(256)) as
-- missing source code
go

create procedure sys.sp_check_constbytable_rowset(@table_name sysname, @table_schema sysname, @constraint_name sysname,
                                                  @constraint_schema sysname) as
-- missing source code
go

create procedure sys.sp_check_constbytable_rowset2(@table_schema sysname, @constraint_name sysname,
                                                   @constraint_schema sysname) as
-- missing source code
go

create procedure sys.sp_check_constraints_rowset(@constraint_name sysname, @constraint_schema sysname) as
-- missing source code
go

create procedure sys.sp_check_constraints_rowset2(@constraint_schema sysname) as
-- missing source code
go

create procedure sys.sp_check_dynamic_filters(@publication sysname) as
-- missing source code
go

create procedure sys.sp_check_for_sync_trigger(@tabid int, @trigger_op char(10), @fonpublisher bit) as
-- missing source code
go

create procedure sys.sp_check_join_filter(@filtered_table nvarchar(400), @join_table nvarchar(400),
                                          @join_filterclause nvarchar(1000)) as
-- missing source code
go

create procedure sys.sp_check_log_shipping_monitor_alert() as
-- missing source code
go

create procedure sys.sp_check_publication_access(@publication sysname, @given_login sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_check_removable(@autofix varchar(4)) as
-- missing source code
go

create procedure sys.sp_check_subset_filter(@filtered_table nvarchar(400), @subset_filterclause nvarchar(1000),
                                            @has_dynamic_filters bit, @dynamic_filters_function_list nvarchar(500)) as
-- missing source code
go

create procedure sys.sp_check_sync_trigger(@trigger_procid int, @trigger_op char(10), @owner sysname) as
-- missing source code
go

create procedure sys.sp_check_trace_enabled_globally(@trace_number int, @trace_status bit) as
-- missing source code
go

create procedure sys.sp_checkinvalidivarticle(@mode tinyint, @publication sysname) as
-- missing source code
go

create procedure sys.sp_clean_db_file_free_space(@dbname sysname, @fileid int, @cleaning_delay int) as
-- missing source code
go

create procedure sys.sp_clean_db_free_space(@dbname sysname, @cleaning_delay int) as
-- missing source code
go

create procedure sys.sp_cleanmergelogfiles(@publication sysname, @subscriber sysname, @subscriber_db sysname,
                                           @publisher sysname, @publisher_db sysname, @web_server sysname, @id int) as
-- missing source code
go

create procedure sys.sp_cleanup_all_average_column_length_statistics() as
-- missing source code
go

create procedure sys.sp_cleanup_all_openrowset_statistics() as
-- missing source code
go

create procedure sys.sp_cleanup_all_user_data_in_master() as
-- missing source code
go

create procedure sys.sp_cleanup_data_retention(@schema_name sysname, @table_name sysname, @rowcount int) as
-- missing source code
go

create procedure sys.sp_cleanup_log_shipping_history(@agent_id uniqueidentifier, @agent_type tinyint) as
-- missing source code
go

create procedure sys.sp_cleanup_temporal_history(@schema_name sysname, @table_name sysname, @rowcount int) as
-- missing source code
go

create procedure sys.sp_cleanupdbreplication() as
-- missing source code
go

create procedure sys.sp_cloud_update_blob_tier() as
-- missing source code
go

create procedure sys.sp_collect_backend_plan() as
-- missing source code
go

create procedure sys.sp_column_privileges(@table_name sysname, @table_owner sysname, @table_qualifier sysname,
                                          @column_name nvarchar(384)) as
-- missing source code
go

create procedure sys.sp_column_privileges_ex(@table_server sysname, @table_name sysname, @table_schema sysname,
                                             @table_catalog sysname, @column_name sysname) as
-- missing source code
go

create procedure sys.sp_column_privileges_rowset(@table_name sysname, @table_schema sysname, @column_name sysname,
                                                 @grantor sysname, @grantee sysname) as
-- missing source code
go

create procedure sys.sp_column_privileges_rowset2(@table_schema sysname, @column_name sysname, @grantor sysname,
                                                  @grantee sysname) as
-- missing source code
go

create procedure sys.sp_column_privileges_rowset_rmt(@table_server sysname, @table_catalog sysname, @table_name sysname,
                                                     @table_schema sysname, @column_name sysname, @grantor sysname,
                                                     @grantee sysname) as
-- missing source code
go

create procedure sys.sp_columns(@table_name nvarchar(384), @table_owner nvarchar(384), @table_qualifier sysname,
                                @column_name nvarchar(384), @ODBCVer int) as
-- missing source code
go

create procedure sys.sp_columns_100(@table_name nvarchar(384), @table_owner nvarchar(384), @table_qualifier sysname,
                                    @column_name nvarchar(384), @NameScope int, @ODBCVer int, @fUsePattern bit) as
-- missing source code
go

create procedure sys.sp_columns_100_rowset(@table_name sysname, @table_schema sysname, @column_name sysname) as
-- missing source code
go

create procedure sys.sp_columns_100_rowset2(@table_schema sysname, @column_name sysname) as
-- missing source code
go

create procedure sys.sp_columns_90(@table_name nvarchar(384), @table_owner nvarchar(384), @table_qualifier sysname,
                                   @column_name nvarchar(384), @ODBCVer int, @fUsePattern bit) as
-- missing source code
go

create procedure sys.sp_columns_90_rowset(@table_name sysname, @table_schema sysname, @column_name sysname) as
-- missing source code
go

create procedure sys.sp_columns_90_rowset2(@table_schema sysname, @column_name sysname) as
-- missing source code
go

create procedure sys.sp_columns_90_rowset_rmt(@table_server sysname, @table_catalog sysname, @table_name sysname,
                                              @table_schema sysname, @column_name sysname) as
-- missing source code
go

create procedure sys.sp_columns_ex(@table_server sysname, @table_name sysname, @table_schema sysname,
                                   @table_catalog sysname, @column_name sysname, @ODBCVer int) as
-- missing source code
go

create procedure sys.sp_columns_ex_100(@table_server sysname, @table_name sysname, @table_schema sysname,
                                       @table_catalog sysname, @column_name sysname, @ODBCVer int, @fUsePattern bit) as
-- missing source code
go

create procedure sys.sp_columns_ex_90(@table_server sysname, @table_name sysname, @table_schema sysname,
                                      @table_catalog sysname, @column_name sysname, @ODBCVer int, @fUsePattern bit) as
-- missing source code
go

create procedure sys.sp_columns_managed(@Catalog sysname, @Owner sysname, @Table sysname, @Column sysname,
                                        @SchemaType sysname) as
-- missing source code
go

create procedure sys.sp_columns_rowset(@table_name sysname, @table_schema sysname, @column_name sysname) as
-- missing source code
go

create procedure sys.sp_columns_rowset2(@table_schema sysname, @column_name sysname) as
-- missing source code
go

create procedure sys.sp_columns_rowset_rmt(@table_server sysname, @table_catalog sysname, @table_name sysname,
                                           @table_schema sysname, @column_name sysname) as
-- missing source code
go

create procedure sys.sp_commit_parallel_nested_tran() as
-- missing source code
go

create procedure sys.sp_configure(@configname varchar(35), @configvalue int) as
-- missing source code
go

create procedure sys.sp_configure_automatic_tuning() as
-- missing source code
go

create procedure sys.sp_configure_peerconflictdetection(@publication sysname, @action nvarchar(32), @originator_id int,
                                                        @conflict_retention int, @continue_onconflict nvarchar(5),
                                                        @local nvarchar(5), @timeout int) as
-- missing source code
go

create procedure sys.sp_constr_col_usage_rowset(@table_name sysname, @table_schema sysname, @column_name sysname,
                                                @constr_catalog sysname, @constr_schema sysname,
                                                @constr_name sysname) as
-- missing source code
go

create procedure sys.sp_constr_col_usage_rowset2(@table_schema sysname, @column_name sysname, @constr_catalog sysname,
                                                 @constr_schema sysname, @constr_name sysname) as
-- missing source code
go

create procedure sys.sp_control_dbmasterkey_password() as
-- missing source code
go

create procedure sys.sp_control_plan_guide(@operation nvarchar(60), @name sysname) as
-- missing source code
go

create procedure sys.sp_copy_data_in_batches() as
-- missing source code
go

create procedure sys.sp_copymergesnapshot(@publication sysname, @destination_folder nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_copysnapshot(@publication sysname, @destination_folder nvarchar(255), @subscriber sysname,
                                     @subscriber_db sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_copysubscription(@filename nvarchar(260), @temp_dir nvarchar(260),
                                         @overwrite_existing_file bit) as
-- missing source code
go

create procedure sys.sp_create_asymmetric_key_from_external_key() as
-- missing source code
go

create procedure sys.sp_create_format_type() as
-- missing source code
go

create procedure sys.sp_create_format_type_synonym() as
-- missing source code
go

create procedure sys.sp_create_openrowset_statistics() as
-- missing source code
go

create procedure sys.sp_create_parser_version() as
-- missing source code
go

create procedure sys.sp_create_plan_guide(@name sysname, @stmt nvarchar(max), @type nvarchar(60),
                                          @module_or_batch nvarchar(max), @params nvarchar(max),
                                          @hints nvarchar(max)) as
-- missing source code
go

create procedure sys.sp_create_plan_guide_from_handle(@name sysname, @plan_handle varbinary(64),
                                                      @statement_start_offset int) as
-- missing source code
go

create procedure sys.sp_create_removable(@dbname sysname, @syslogical sysname, @sysphysical nvarchar(260), @syssize int,
                                         @loglogical sysname, @logphysical nvarchar(260), @logsize int,
                                         @datalogical1 sysname, @dataphysical1 nvarchar(260), @datasize1 int,
                                         @datalogical2 sysname, @dataphysical2 nvarchar(260), @datasize2 int,
                                         @datalogical3 sysname, @dataphysical3 nvarchar(260), @datasize3 int,
                                         @datalogical4 sysname, @dataphysical4 nvarchar(260), @datasize4 int,
                                         @datalogical5 sysname, @dataphysical5 nvarchar(260), @datasize5 int,
                                         @datalogical6 sysname, @dataphysical6 nvarchar(260), @datasize6 int,
                                         @datalogical7 sysname, @dataphysical7 nvarchar(260), @datasize7 int,
                                         @datalogical8 sysname, @dataphysical8 nvarchar(260), @datasize8 int,
                                         @datalogical9 sysname, @dataphysical9 nvarchar(260), @datasize9 int,
                                         @datalogical10 sysname, @dataphysical10 nvarchar(260), @datasize10 int,
                                         @datalogical11 sysname, @dataphysical11 nvarchar(260), @datasize11 int,
                                         @datalogical12 sysname, @dataphysical12 nvarchar(260), @datasize12 int,
                                         @datalogical13 sysname, @dataphysical13 nvarchar(260), @datasize13 int,
                                         @datalogical14 sysname, @dataphysical14 nvarchar(260), @datasize14 int,
                                         @datalogical15 sysname, @dataphysical15 nvarchar(260), @datasize15 int,
                                         @datalogical16 sysname, @dataphysical16 nvarchar(260), @datasize16 int) as
-- missing source code
go

create procedure sys.sp_create_streaming_job(@name sysname, @statement nvarchar(max), @streams nvarchar(max),
                                             @publicKey varbinary(512)) as
-- missing source code
go

create procedure sys.sp_createmergepalrole(@publication sysname) as
-- missing source code
go

create procedure sys.sp_createorphan() as
-- missing source code
go

create procedure sys.sp_createstats(@indexonly char(9), @fullscan char(9), @norecompute char(12),
                                    @incremental char(12)) as
-- missing source code
go

create procedure sys.sp_createtranpalrole(@publication sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_cursor() as
-- missing source code
go

create procedure sys.sp_cursor_list(@cursor_scope int) returns int as
-- missing source code
go

create procedure sys.sp_cursorclose() as
-- missing source code
go

create procedure sys.sp_cursorexecute() as
-- missing source code
go

create procedure sys.sp_cursorfetch() as
-- missing source code
go

create procedure sys.sp_cursoropen() as
-- missing source code
go

create procedure sys.sp_cursoroption() as
-- missing source code
go

create procedure sys.sp_cursorprepare() as
-- missing source code
go

create procedure sys.sp_cursorprepexec() as
-- missing source code
go

create procedure sys.sp_cursorunprepare() as
-- missing source code
go

create procedure sys.sp_cycle_errorlog() as
-- missing source code
go

create procedure sys.sp_data_pool_database_query_state(@db_name sysname, @database_state sysname) as
-- missing source code
go

create procedure sys.sp_data_pool_table_query_state(@pool_name sysname, @db_name sysname, @schema_name sysname,
                                                    @table_name sysname, @table_state sysname) as
-- missing source code
go

create procedure sys.sp_data_source_objects(@data_source sysname, @object_root_name nvarchar(max),
                                            @max_search_depth int, @search_options nvarchar(max)) as
-- missing source code
go

create procedure sys.sp_data_source_table_columns(@data_source sysname, @table_location nvarchar(max),
                                                  @column_name nvarchar(max), @search_options nvarchar(max)) as
-- missing source code
go

create procedure sys.sp_databases() as
-- missing source code
go

create procedure sys.sp_datatype_info(@data_type int, @ODBCVer tinyint) as
-- missing source code
go

create procedure sys.sp_datatype_info_100(@data_type int, @ODBCVer tinyint) as
-- missing source code
go

create procedure sys.sp_datatype_info_90(@data_type int, @ODBCVer tinyint) as
-- missing source code
go

create procedure sys.sp_db_ebcdic277_2(@dbname sysname, @status varchar(6)) as
-- missing source code
go

create procedure sys.sp_db_increased_partitions(@dbname sysname, @increased_partitions varchar(6)) as
-- missing source code
go

create procedure sys.sp_db_selective_xml_index(@dbname sysname, @selective_xml_index varchar(6)) as
-- missing source code
go

create procedure sys.sp_db_vardecimal_storage_format(@dbname sysname, @vardecimal_storage_format varchar(3)) as
-- missing source code
go

create procedure sys.sp_dbcmptlevel(@dbname sysname, @new_cmptlevel tinyint) as
-- missing source code
go

create procedure sys.sp_dbfixedrolepermission(@rolename sysname) as
-- missing source code
go

create procedure sys.sp_dbmmonitoraddmonitoring(@update_period int) as
-- missing source code
go

create procedure sys.sp_dbmmonitorchangealert(@database_name sysname, @alert_id int, @threshold int, @enabled bit) as
-- missing source code
go

create procedure sys.sp_dbmmonitorchangemonitoring(@parameter_id int, @value int) as
-- missing source code
go

create procedure sys.sp_dbmmonitordropalert(@database_name sysname, @alert_id int) as
-- missing source code
go

create procedure sys.sp_dbmmonitordropmonitoring() as
-- missing source code
go

create procedure sys.sp_dbmmonitorhelpalert(@database_name sysname, @alert_id int) as
-- missing source code
go

create procedure sys.sp_dbmmonitorhelpmonitoring() as
-- missing source code
go

create procedure sys.sp_dbmmonitorresults(@database_name sysname, @mode int, @update_table int) as
-- missing source code
go

create procedure sys.sp_dbmmonitorupdate(@database_name sysname) as
-- missing source code
go

create procedure sys.sp_dbremove(@dbname sysname, @dropdev varchar(10)) as
-- missing source code
go

create procedure sys.sp_ddopen(@handle int, @procname sysname, @scrollopt int, @ccopt int, @rows int, @p1 nvarchar(774),
                               @p2 nvarchar(774), @p3 nvarchar(774), @p4 nvarchar(774), @p5 nvarchar(774),
                               @p6 nvarchar(774), @p7 int, @NameScope int, @ODBCVer int, @fUsePattern bit) as
-- missing source code
go

create procedure sys.sp_defaultdb(@loginame sysname, @defdb sysname) as
-- missing source code
go

create procedure sys.sp_defaultlanguage(@loginame sysname, @language sysname) as
-- missing source code
go

create procedure sys.sp_delete_backup(@backup_url nvarchar(360), @database_name sysname) as
-- missing source code
go

create procedure sys.sp_delete_backup_file_snapshot() as
-- missing source code
go

create procedure sys.sp_delete_database_engine_configuration_internal() as
-- missing source code
go

create procedure sys.sp_delete_http_namespace_reservation() as
-- missing source code
go

create procedure sys.sp_delete_log_shipping_alert_job() as
-- missing source code
go

create procedure sys.sp_delete_log_shipping_primary_database(@database sysname, @ignoreremotemonitor bit) as
-- missing source code
go

create procedure sys.sp_delete_log_shipping_primary_secondary(@primary_database sysname, @secondary_server sysname,
                                                              @secondary_database sysname) as
-- missing source code
go

create procedure sys.sp_delete_log_shipping_secondary_database(@secondary_database sysname, @ignoreremotemonitor bit) as
-- missing source code
go

create procedure sys.sp_delete_log_shipping_secondary_primary(@primary_server sysname, @primary_database sysname) as
-- missing source code
go

create procedure sys.sp_deletemergeconflictrow(@conflict_table sysname, @source_object nvarchar(386),
                                               @rowguid uniqueidentifier, @origin_datasource varchar(255),
                                               @drop_table_if_empty varchar(10)) as
-- missing source code
go

create procedure sys.sp_deletepeerrequesthistory(@publication sysname, @request_id int, @cutoff_date datetime) as
-- missing source code
go

create procedure sys.sp_deletetracertokenhistory(@publication sysname, @tracer_id int, @cutoff_date datetime,
                                                 @publisher sysname, @publisher_db sysname) as
-- missing source code
go

create procedure sys.sp_denylogin(@loginame sysname) as
-- missing source code
go

create procedure sys.sp_depends(@objname nvarchar(776)) as
-- missing source code
go

create procedure sys.sp_describe_cursor(@cursor_source nvarchar(30), @cursor_identity nvarchar(128)) returns int as
-- missing source code
go

create procedure sys.sp_describe_cursor_columns(@cursor_source nvarchar(30), @cursor_identity nvarchar(128)) returns int as
-- missing source code
go

create procedure sys.sp_describe_cursor_tables(@cursor_source nvarchar(30), @cursor_identity nvarchar(128)) returns int as
-- missing source code
go

create procedure sys.sp_describe_first_result_set() as
-- missing source code
go

create procedure sys.sp_describe_parameter_encryption() as
-- missing source code
go

create procedure sys.sp_describe_undeclared_parameters() as
-- missing source code
go

create procedure sys.sp_detach_db(@dbname sysname, @skipchecks nvarchar(10), @keepfulltextindexfile nvarchar(10)) as
-- missing source code
go

create procedure sys.sp_diagnostic_showplan_log_dbid() as
-- missing source code
go

create procedure sys.sp_disableagentoffload(@job_id varbinary(16), @offloadserver sysname, @agent_type sysname) as
-- missing source code
go

create procedure sys.sp_discover_trident_table(@TableName nvarchar(256)) as
-- missing source code
go

create procedure sys.sp_distcounters() as
-- missing source code
go

create procedure sys.sp_drop_agent_parameter(@profile_id int, @parameter_name sysname) as
-- missing source code
go

create procedure sys.sp_drop_agent_profile(@profile_id int) as
-- missing source code
go

create procedure sys.sp_drop_format_type() as
-- missing source code
go

create procedure sys.sp_drop_openrowset_statistics() as
-- missing source code
go

create procedure sys.sp_drop_parser_version() as
-- missing source code
go

create procedure sys.sp_drop_storage_location() as
-- missing source code
go

create procedure sys.sp_drop_streaming_job(@name sysname, @force bit) as
-- missing source code
go

create procedure sys.sp_drop_trident_data_location() as
-- missing source code
go

create procedure sys.sp_drop_trusted_assembly() as
-- missing source code
go

create procedure sys.sp_dropanonymousagent(@subid uniqueidentifier, @type int) as
-- missing source code
go

create procedure sys.sp_dropanonymoussubscription(@agent_id int, @type int) as
-- missing source code
go

create procedure sys.sp_dropapprole(@rolename sysname) as
-- missing source code
go

create procedure sys.sp_droparticle(@publication sysname, @article sysname, @ignore_distributor bit,
                                    @force_invalidate_snapshot bit, @publisher sysname, @from_drop_publication bit) as
-- missing source code
go

create procedure sys.sp_dropdatatypemapping(@mapping_id int, @source_dbms sysname, @source_version sysname,
                                            @source_type sysname, @source_length_min bigint, @source_length_max bigint,
                                            @source_precision_min bigint, @source_precision_max bigint,
                                            @source_scale_min int, @source_scale_max int, @source_nullable bit,
                                            @destination_dbms sysname, @destination_version sysname,
                                            @destination_type sysname, @destination_length bigint,
                                            @destination_precision bigint, @destination_scale int,
                                            @destination_nullable bit) as
-- missing source code
go

create procedure sys.sp_dropdevice(@logicalname sysname, @delfile varchar(7)) as
-- missing source code
go

create procedure sys.sp_dropdistpublisher(@publisher sysname, @no_checks bit, @ignore_distributor bit) as
-- missing source code
go

create procedure sys.sp_dropdistributiondb(@database sysname, @former_ag_secondary int) as
-- missing source code
go

create procedure sys.sp_dropdistributor(@no_checks bit, @ignore_distributor bit) as
-- missing source code
go

create procedure sys.sp_dropdynamicsnapshot_job(@publication sysname, @dynamic_snapshot_jobname sysname,
                                                @dynamic_snapshot_jobid uniqueidentifier, @ignore_distributor bit) as
-- missing source code
go

create procedure sys.sp_dropextendedproc(@functname nvarchar(517)) as
-- missing source code
go

create procedure sys.sp_dropextendedproperty(@name sysname, @level0type varchar(128), @level0name sysname,
                                             @level1type varchar(128), @level1name sysname, @level2type varchar(128),
                                             @level2name sysname) as
-- missing source code
go

create procedure sys.sp_droplinkedsrvlogin(@rmtsrvname sysname, @locallogin sysname) as
-- missing source code
go

create procedure sys.sp_droplogin(@loginame sysname) as
-- missing source code
go

create procedure sys.sp_dropmergealternatepublisher(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                    @alternate_publisher sysname, @alternate_publisher_db sysname,
                                                    @alternate_publication sysname) as
-- missing source code
go

create procedure sys.sp_dropmergearticle(@publication sysname, @article sysname, @ignore_distributor bit, @reserved bit,
                                         @force_invalidate_snapshot bit, @force_reinit_subscription bit,
                                         @ignore_merge_metadata bit) as
-- missing source code
go

create procedure sys.sp_dropmergefilter(@publication sysname, @article sysname, @filtername sysname,
                                        @force_invalidate_snapshot bit, @force_reinit_subscription bit) as
-- missing source code
go

create procedure sys.sp_dropmergelogsettings(@publication sysname, @subscriber sysname, @subscriber_db sysname,
                                             @web_server sysname) as
-- missing source code
go

create procedure sys.sp_dropmergepartition(@publication sysname, @suser_sname sysname, @host_name sysname) as
-- missing source code
go

create procedure sys.sp_dropmergepublication(@publication sysname, @ignore_distributor bit, @reserved bit,
                                             @ignore_merge_metadata bit) as
-- missing source code
go

create procedure sys.sp_dropmergepullsubscription(@publication sysname, @publisher sysname, @publisher_db sysname,
                                                  @reserved bit) as
-- missing source code
go

create procedure sys.sp_dropmergesubscription(@publication sysname, @subscriber sysname, @subscriber_db sysname,
                                              @subscription_type nvarchar(15), @ignore_distributor bit,
                                              @reserved bit) as
-- missing source code
go

create procedure sys.sp_dropmessage(@msgnum int, @lang sysname) as
-- missing source code
go

create procedure sys.sp_droporphans() as
-- missing source code
go

create procedure sys.sp_droppublication(@publication sysname, @ignore_distributor bit, @publisher sysname,
                                        @from_backup bit) as
-- missing source code
go

create procedure sys.sp_droppublisher(@publisher sysname, @type nvarchar(5)) as
-- missing source code
go

create procedure sys.sp_droppullsubscription(@publisher sysname, @publisher_db sysname, @publication sysname,
                                             @reserved bit, @from_backup bit) as
-- missing source code
go

create procedure sys.sp_dropremotelogin(@remoteserver sysname, @loginame sysname, @remotename sysname) as
-- missing source code
go

create procedure sys.sp_dropreplsymmetrickey(@check_replication bit, @throw_error bit) as
-- missing source code
go

create procedure sys.sp_droprole(@rolename sysname) as
-- missing source code
go

create procedure sys.sp_droprolemember(@rolename sysname, @membername sysname) as
-- missing source code
go

create procedure sys.sp_dropserver(@server sysname, @droplogins char(10)) as
-- missing source code
go

create procedure sys.sp_dropsrvrolemember(@loginame sysname, @rolename sysname) as
-- missing source code
go

create procedure sys.sp_dropsubscriber(@subscriber sysname, @reserved nvarchar(50), @ignore_distributor bit,
                                       @publisher sysname) as
-- missing source code
go

create procedure sys.sp_dropsubscription(@publication sysname, @article sysname, @subscriber sysname,
                                         @destination_db sysname, @ignore_distributor bit, @reserved nvarchar(10),
                                         @publisher sysname) as
-- missing source code
go

create procedure sys.sp_droptype(@typename sysname) as
-- missing source code
go

create procedure sys.sp_dropuser(@name_in_db sysname) as
-- missing source code
go

create procedure sys.sp_dsninfo(@dsn varchar(128), @infotype varchar(128), @login varchar(128), @password varchar(128),
                                @dso_type int) as
-- missing source code
go

create procedure sys.sp_dw_physical_manifest_file_table_insert() as
-- missing source code
go

create procedure sys.sp_dw_physical_upsert() as
-- missing source code
go

create procedure sys.sp_enable_heterogeneous_subscription(@publication sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_enable_sql_debug() as
-- missing source code
go

create procedure sys.sp_enableagentoffload(@job_id varbinary(16), @offloadserver sysname, @agent_type sysname) as
-- missing source code
go

create procedure sys.sp_enclave_send_keys() as
-- missing source code
go

create procedure sys.sp_enum_oledb_providers() as
-- missing source code
go

create procedure sys.sp_enumcustomresolvers(@distributor sysname) as
-- missing source code
go

create procedure sys.sp_enumdsn() as
-- missing source code
go

create procedure sys.sp_enumeratependingschemachanges(@publication sysname, @starting_schemaversion int) as
-- missing source code
go

create procedure sys.sp_enumerrorlogs(@p1 int) as
-- missing source code
go

create procedure sys.sp_enumfullsubscribers(@publication sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_enumoledbdatasources() as
-- missing source code
go

create procedure sys.sp_estimate_data_compression_savings(@schema_name sysname, @object_name sysname, @index_id int,
                                                          @partition_number int, @data_compression nvarchar(60),
                                                          @xml_compression bit) as
-- missing source code
go

create procedure sys.sp_estimated_rowsize_reduction_for_vardecimal(@table_name nvarchar(776)) as
-- missing source code
go

create procedure sys.sp_execute() as
-- missing source code
go

create procedure sys.sp_execute_external_script() as
-- missing source code
go

create procedure sys.sp_execute_flight_query() as
-- missing source code
go

create procedure sys.sp_execute_remote() as
-- missing source code
go

create procedure sys.sp_executesql() as
-- missing source code
go

create procedure sys.sp_executesql_metrics() as
-- missing source code
go

create procedure sys.sp_expired_subscription_cleanup(@publisher sysname) as
-- missing source code
go

create procedure sys.sp_external_policy_refresh() as
-- missing source code
go

create procedure sys.sp_fido_build_basic_histogram() as
-- missing source code
go

create procedure sys.sp_fido_build_histogram() as
-- missing source code
go

create procedure sys.sp_fido_execute_graph_request() as
-- missing source code
go

create procedure sys.sp_fido_get_CS_rowset_row_count() as
-- missing source code
go

create procedure sys.sp_fido_get_remote_storage_size() as
-- missing source code
go

create procedure sys.sp_fido_glm_server_execute_batch() as
-- missing source code
go

create procedure sys.sp_fido_glms_execute_command() as
-- missing source code
go

create procedure sys.sp_fido_glms_get_storage_containers() as
-- missing source code
go

create procedure sys.sp_fido_glms_set_storage_containers() as
-- missing source code
go

create procedure sys.sp_fido_glms_unregister_appname() as
-- missing source code
go

create procedure sys.sp_fido_indexstore_update_topology() as
-- missing source code
go

create procedure sys.sp_fido_indexstore_upgrade_node() as
-- missing source code
go

create procedure sys.sp_fido_remove_retention_policy() as
-- missing source code
go

create procedure sys.sp_fido_set_ddl_step() as
-- missing source code
go

create procedure sys.sp_fido_set_retention_policy() as
-- missing source code
go

create procedure sys.sp_fido_set_tran() as
-- missing source code
go

create procedure sys.sp_fido_setup_endpoints() as
-- missing source code
go

create procedure sys.sp_fido_setup_glms() as
-- missing source code
go

create procedure sys.sp_fido_spaceused(@objname nvarchar(776), @updateusage varchar(5), @oneresultset bit) as
-- missing source code
go

create procedure sys.sp_fido_tran_abort() as
-- missing source code
go

create procedure sys.sp_fido_tran_begin() as
-- missing source code
go

create procedure sys.sp_fido_tran_commit() as
-- missing source code
go

create procedure sys.sp_fido_tran_get_state() as
-- missing source code
go

create procedure sys.sp_fido_tran_set_token() as
-- missing source code
go

create procedure sys.sp_filestream_force_garbage_collection(@dbname sysname, @filename sysname) as
-- missing source code
go

create procedure sys.sp_filestream_recalculate_container_size(@dbname sysname, @filename sysname) as
-- missing source code
go

create procedure sys.sp_firstonly_bitmap(@inputbitmap1 varbinary(128), @inputbitmap2 varbinary(128),
                                         @resultbitmap3 varbinary(128)) as
-- missing source code
go

create procedure sys.sp_fkeys(@pktable_name sysname, @pktable_owner sysname, @pktable_qualifier sysname,
                              @fktable_name sysname, @fktable_owner sysname, @fktable_qualifier sysname) as
-- missing source code
go

create procedure sys.sp_flush_CT_internal_table_on_demand(@TableToClean sysname, @DeletedRowCount bigint) as
-- missing source code
go

create procedure sys.sp_flush_commit_table(@flush_ts bigint, @cleanup_version bigint) as
-- missing source code
go

create procedure sys.sp_flush_commit_table_on_demand(@numrows bigint, @deleted_rows bigint, @date_cleanedup datetime,
                                                     @cleanup_ts bigint) as
-- missing source code
go

create procedure sys.sp_flush_log() as
-- missing source code
go

create procedure sys.sp_force_slog_truncation() as
-- missing source code
go

create procedure sys.sp_foreign_keys_rowset(@pk_table_name sysname, @pk_table_schema sysname,
                                            @foreignkey_tab_name sysname, @foreignkey_tab_schema sysname,
                                            @foreignkey_tab_catalog sysname) as
-- missing source code
go

create procedure sys.sp_foreign_keys_rowset2(@foreignkey_tab_name sysname, @foreignkey_tab_schema sysname,
                                             @pk_table_name sysname, @pk_table_schema sysname,
                                             @pk_table_catalog sysname) as
-- missing source code
go

create procedure sys.sp_foreign_keys_rowset3(@pk_table_schema sysname, @pk_table_catalog sysname,
                                             @foreignkey_tab_schema sysname, @foreignkey_tab_catalog sysname) as
-- missing source code
go

create procedure sys.sp_foreign_keys_rowset_rmt(@server_name sysname, @pk_table_name sysname, @pk_table_schema sysname,
                                                @pk_table_catalog sysname, @foreignkey_tab_name sysname,
                                                @foreignkey_tab_schema sysname, @foreignkey_tab_catalog sysname) as
-- missing source code
go

create procedure sys.sp_foreignkeys(@table_server sysname, @pktab_name sysname, @pktab_schema sysname,
                                    @pktab_catalog sysname, @fktab_name sysname, @fktab_schema sysname,
                                    @fktab_catalog sysname) as
-- missing source code
go

create procedure sys.sp_fulltext_catalog(@ftcat sysname, @action varchar(20), @path nvarchar(101)) as
-- missing source code
go

create procedure sys.sp_fulltext_column(@tabname nvarchar(517), @colname sysname, @action varchar(20), @language int,
                                        @type_colname sysname) as
-- missing source code
go

create procedure sys.sp_fulltext_database(@action varchar(20)) as
-- missing source code
go

create procedure sys.sp_fulltext_getdata() as
-- missing source code
go

create procedure sys.sp_fulltext_keymappings() as
-- missing source code
go

create procedure sys.sp_fulltext_load_thesaurus_file(@lcid int, @loadOnlyIfNotLoaded bit) as
-- missing source code
go

create procedure sys.sp_fulltext_pendingchanges() as
-- missing source code
go

create procedure sys.sp_fulltext_recycle_crawl_log(@ftcat sysname) as
-- missing source code
go

create procedure sys.sp_fulltext_semantic_register_language_statistics_db(@dbname sysname) as
-- missing source code
go

create procedure sys.sp_fulltext_semantic_unregister_language_statistics_db() as
-- missing source code
go

create procedure sys.sp_fulltext_service(@action nvarchar(100), @value sql_variant) as
-- missing source code
go

create procedure sys.sp_fulltext_table(@tabname nvarchar(517), @action varchar(50), @ftcat sysname, @keyname sysname) as
-- missing source code
go

create procedure sys.sp_generate_agent_parameter(@profile_id int, @real_profile_id int) as
-- missing source code
go

create procedure sys.sp_generate_database_ledger_digest() as
-- missing source code
go

create procedure sys.sp_generate_external_table_statistics_description_and_hash() as
-- missing source code
go

create procedure sys.sp_generate_openrowset_statistics_props() as
-- missing source code
go

create procedure sys.sp_generate_trident_table_manifest() as
-- missing source code
go

create procedure sys.sp_generatefilters(@publication sysname) as
-- missing source code
go

create procedure sys.sp_getProcessorUsage() as
-- missing source code
go

create procedure sys.sp_getVolumeFreeSpace(@database_name sysname, @file_id int) as
-- missing source code
go

create procedure sys.sp_get_Oracle_publisher_metadata(@database_name sysname) as
-- missing source code
go

create procedure sys.sp_get_database_scoped_credential() as
-- missing source code
go

create procedure sys.sp_get_distributor() as
-- missing source code
go

create procedure sys.sp_get_dmv_collector_views() as
-- missing source code
go

create procedure sys.sp_get_endpoint_certificate() as
-- missing source code
go

create procedure sys.sp_get_external_table_cardinality() as
-- missing source code
go

create procedure sys.sp_get_fido_lock() as
-- missing source code
go

create procedure sys.sp_get_fido_lock_batch() as
-- missing source code
go

create procedure sys.sp_get_file_splits() as
-- missing source code
go

create procedure sys.sp_get_job_status_mergesubscription_agent(@publisher sysname, @publisher_db sysname,
                                                               @publication sysname, @agent_name nvarchar(100)) as
-- missing source code
go

create procedure sys.sp_get_mergepublishedarticleproperties(@source_object sysname, @source_owner sysname) as
-- missing source code
go

create procedure sys.sp_get_migration_vlf_state() as
-- missing source code
go

create procedure sys.sp_get_openrowset_statistics_additional_props() as
-- missing source code
go

create procedure sys.sp_get_openrowset_statistics_cardinality() as
-- missing source code
go

create procedure sys.sp_get_query_template() as
-- missing source code
go

create procedure sys.sp_get_redirected_publisher(@original_publisher sysname, @publisher_db sysname,
                                                 @bypass_publisher_validation bit) as
-- missing source code
go

create procedure sys.sp_get_streaming_job(@name sysname) as
-- missing source code
go

create procedure sys.sp_get_table_card_est_and_avg_col_len() as
-- missing source code
go

create procedure sys.sp_get_total_openrowset_statistics_count() as
-- missing source code
go

create procedure sys.sp_get_trident_data_location() as
-- missing source code
go

create procedure sys.sp_getagentparameterlist(@agent_type int) as
-- missing source code
go

create procedure sys.sp_getapplock(@Resource nvarchar(255), @LockMode varchar(32), @LockOwner varchar(32),
                                   @LockTimeout int, @DbPrincipal sysname) as
-- missing source code
go

create procedure sys.sp_getbindtoken() as
-- missing source code
go

create procedure sys.sp_getdefaultdatatypemapping(@source_dbms sysname, @source_version varchar(10),
                                                  @source_type sysname, @source_length bigint, @source_precision int,
                                                  @source_scale int, @source_nullable bit, @destination_dbms sysname,
                                                  @destination_version varchar(10), @destination_type sysname,
                                                  @destination_length bigint, @destination_precision int,
                                                  @destination_scale int, @destination_nullable bit, @dataloss bit) as
-- missing source code
go

create procedure sys.sp_getdistributorplatform(@hostplatform nvarchar(256)) as
-- missing source code
go

create procedure sys.sp_getmergedeletetype(@source_object nvarchar(386), @rowguid uniqueidentifier, @delete_type int) as
-- missing source code
go

create procedure sys.sp_getpublisherlink(@trigger_id int, @connect_string nvarchar(300), @islocalpublisher bit) as
-- missing source code
go

create procedure sys.sp_getqueuedarticlesynctraninfo(@publication sysname, @artid int) as
-- missing source code
go

create procedure sys.sp_getqueuedrows(@tablename sysname, @owner sysname, @tranid nvarchar(70)) as
-- missing source code
go

create procedure sys.sp_getschemalock() as
-- missing source code
go

create procedure sys.sp_getsqlqueueversion(@publisher sysname, @publisher_db sysname, @publication sysname,
                                           @version int) as
-- missing source code
go

create procedure sys.sp_getsubscription_status_hsnapshot(@publication sysname, @article sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_getsubscriptiondtspackagename(@publication sysname, @subscriber sysname) as
-- missing source code
go

create procedure sys.sp_gettopologyinfo(@request_id int) as
-- missing source code
go

create procedure sys.sp_grant_publication_access(@publication sysname, @login sysname, @reserved nvarchar(10),
                                                 @publisher sysname) as
-- missing source code
go

create procedure sys.sp_grantdbaccess(@loginame sysname, @name_in_db sysname) as
-- missing source code
go

create procedure sys.sp_grantlogin(@loginame sysname) as
-- missing source code
go

create procedure sys.sp_help(@objname nvarchar(776)) as
-- missing source code
go

create procedure sys.sp_help_agent_default(@profile_id int, @agent_type int) as
-- missing source code
go

create procedure sys.sp_help_agent_parameter(@profile_id int) as
-- missing source code
go

create procedure sys.sp_help_agent_profile(@agent_type int, @profile_id int) as
-- missing source code
go

create procedure sys.sp_help_change_feed() as
-- missing source code
go

create procedure sys.sp_help_change_feed_table(@table_group_id uniqueidentifier, @table_id uniqueidentifier,
                                               @source_schema sysname, @source_name sysname) as
-- missing source code
go

create procedure sys.sp_help_datatype_mapping(@dbms_name sysname, @dbms_version sysname, @sql_type sysname,
                                              @source_prec int) as
-- missing source code
go

create procedure sys.sp_help_fulltext_catalog_components() as
-- missing source code
go

create procedure sys.sp_help_fulltext_catalogs(@fulltext_catalog_name sysname) as
-- missing source code
go

create procedure sys.sp_help_fulltext_catalogs_cursor(@fulltext_catalog_name sysname) returns int as
-- missing source code
go

create procedure sys.sp_help_fulltext_columns(@table_name nvarchar(517), @column_name sysname) as
-- missing source code
go

create procedure sys.sp_help_fulltext_columns_cursor(@table_name nvarchar(517), @column_name sysname) returns int as
-- missing source code
go

create procedure sys.sp_help_fulltext_system_components(@component_type sysname, @param sysname) as
-- missing source code
go

create procedure sys.sp_help_fulltext_tables(@fulltext_catalog_name sysname, @table_name nvarchar(517)) as
-- missing source code
go

create procedure sys.sp_help_fulltext_tables_cursor(@fulltext_catalog_name sysname, @table_name nvarchar(517)) returns int as
-- missing source code
go

create procedure sys.sp_help_log_shipping_alert_job() as
-- missing source code
go

create procedure sys.sp_help_log_shipping_monitor(@verbose bit) as
-- missing source code
go

create procedure sys.sp_help_log_shipping_monitor_primary(@primary_server sysname, @primary_database sysname) as
-- missing source code
go

create procedure sys.sp_help_log_shipping_monitor_secondary(@secondary_server sysname, @secondary_database sysname) as
-- missing source code
go

create procedure sys.sp_help_log_shipping_primary_database(@database sysname, @primary_id uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_help_log_shipping_primary_secondary(@primary_database sysname) as
-- missing source code
go

create procedure sys.sp_help_log_shipping_secondary_database(@secondary_database sysname, @secondary_id uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_help_log_shipping_secondary_primary(@primary_server sysname, @primary_database sysname) as
-- missing source code
go

create procedure sys.sp_help_peerconflictdetection(@publication sysname, @timeout int) as
-- missing source code
go

create procedure sys.sp_help_publication_access(@publication sysname, @return_granted bit, @login sysname,
                                                @initial_list bit, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_help_spatial_geography_histogram(@tabname sysname, @colname sysname, @resolution int, @sample float) as
-- missing source code
go

create procedure sys.sp_help_spatial_geography_index(@tabname nvarchar(776), @indexname sysname, @verboseoutput tinyint,
                                                     @query_sample geography) as
-- missing source code
go

create procedure sys.sp_help_spatial_geography_index_xml(@tabname nvarchar(776), @indexname sysname,
                                                         @verboseoutput tinyint, @query_sample geography,
                                                         @xml_output xml) as
-- missing source code
go

create procedure sys.sp_help_spatial_geometry_histogram(@tabname sysname, @colname sysname, @resolution int,
                                                        @xmin float, @ymin float, @xmax float, @ymax float,
                                                        @sample float) as
-- missing source code
go

create procedure sys.sp_help_spatial_geometry_index(@tabname nvarchar(776), @indexname sysname, @verboseoutput tinyint,
                                                    @query_sample geometry) as
-- missing source code
go

create procedure sys.sp_help_spatial_geometry_index_xml(@tabname nvarchar(776), @indexname sysname,
                                                        @verboseoutput tinyint, @query_sample geometry,
                                                        @xml_output xml) as
-- missing source code
go

create procedure sys.sp_helpallowmerge_publication() as
-- missing source code
go

create procedure sys.sp_helparticle(@publication sysname, @article sysname, @returnfilter bit, @publisher sysname,
                                    @found int) as
-- missing source code
go

create procedure sys.sp_helparticlecolumns(@publication sysname, @article sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_helparticledts(@publication sysname, @article sysname) as
-- missing source code
go

create procedure sys.sp_helpconstraint(@objname nvarchar(776), @nomsg varchar(5)) as
-- missing source code
go

create procedure sys.sp_helpdatatypemap(@source_dbms sysname, @source_version varchar(10), @source_type sysname,
                                        @destination_dbms sysname, @destination_version varchar(10),
                                        @destination_type sysname, @defaults_only bit) as
-- missing source code
go

create procedure sys.sp_helpdb(@dbname sysname) as
-- missing source code
go

create procedure sys.sp_helpdbfixedrole(@rolename sysname) as
-- missing source code
go

create procedure sys.sp_helpdevice(@devname sysname) as
-- missing source code
go

create procedure sys.sp_helpdistpublisher(@publisher sysname, @check_user bit) as
-- missing source code
go

create procedure sys.sp_helpdistributiondb(@database sysname) as
-- missing source code
go

create procedure sys.sp_helpdistributor(@distributor sysname, @distribdb sysname, @directory nvarchar(255),
                                        @account nvarchar(255), @min_distretention int, @max_distretention int,
                                        @history_retention int, @history_cleanupagent nvarchar(100),
                                        @distrib_cleanupagent nvarchar(100), @publisher sysname, @local nvarchar(5),
                                        @rpcsrvname sysname, @publisher_type sysname, @deletebatchsize_xact int,
                                        @deletebatchsize_cmd int, @dist_listener sysname) as
-- missing source code
go

create procedure sys.sp_helpdistributor_properties() as
-- missing source code
go

create procedure sys.sp_helpdynamicsnapshot_job(@publication sysname, @dynamic_snapshot_jobname sysname,
                                                @dynamic_snapshot_jobid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_helpextendedproc(@funcname sysname) as
-- missing source code
go

create procedure sys.sp_helpfile(@filename sysname) as
-- missing source code
go

create procedure sys.sp_helpfilegroup(@filegroupname sysname) as
-- missing source code
go

create procedure sys.sp_helpindex(@objname nvarchar(776)) as
-- missing source code
go

create procedure sys.sp_helplanguage(@language sysname) as
-- missing source code
go

create procedure sys.sp_helplinkedsrvlogin(@rmtsrvname sysname, @locallogin sysname) as
-- missing source code
go

create procedure sys.sp_helplogins(@LoginNamePattern sysname) as
-- missing source code
go

create procedure sys.sp_helplogreader_agent(@publisher sysname) as
-- missing source code
go

create procedure sys.sp_helpmergealternatepublisher(@publisher sysname, @publisher_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_helpmergearticle(@publication sysname, @article sysname) as
-- missing source code
go

create procedure sys.sp_helpmergearticlecolumn(@publication sysname, @article sysname) as
-- missing source code
go

create procedure sys.sp_helpmergearticleconflicts(@publication sysname, @publisher sysname, @publisher_db sysname) as
-- missing source code
go

create procedure sys.sp_helpmergeconflictrows(@publication sysname, @conflict_table sysname, @publisher sysname,
                                              @publisher_db sysname, @logical_record_conflicts int) as
-- missing source code
go

create procedure sys.sp_helpmergedeleteconflictrows(@publication sysname, @source_object nvarchar(386),
                                                    @publisher sysname, @publisher_db sysname,
                                                    @logical_record_conflicts int) as
-- missing source code
go

create procedure sys.sp_helpmergefilter(@publication sysname, @article sysname, @filtername sysname,
                                        @filter_type_bm binary) as
-- missing source code
go

create procedure sys.sp_helpmergelogfiles(@publication sysname, @subscriber sysname, @subscriber_db sysname,
                                          @publisher sysname, @publisher_db sysname, @web_server sysname) as
-- missing source code
go

create procedure sys.sp_helpmergelogfileswithdata(@publication sysname, @subscriber sysname, @subscriber_db sysname,
                                                  @publisher sysname, @publisher_db sysname, @web_server sysname,
                                                  @id int) as
-- missing source code
go

create procedure sys.sp_helpmergelogsettings(@publication sysname, @subscriber sysname, @subscriber_db sysname,
                                             @publisher sysname, @publisher_db sysname) as
-- missing source code
go

create procedure sys.sp_helpmergepartition(@publication sysname, @suser_sname sysname, @host_name sysname) as
-- missing source code
go

create procedure sys.sp_helpmergepublication(@publication sysname, @found int, @publication_id uniqueidentifier,
                                             @reserved nvarchar(20), @publisher sysname, @publisher_db sysname) as
-- missing source code
go

create procedure sys.sp_helpmergepullsubscription(@publication sysname, @publisher sysname, @publisher_db sysname,
                                                  @subscription_type nvarchar(10)) as
-- missing source code
go

create procedure sys.sp_helpmergesubscription(@publication sysname, @subscriber sysname, @subscriber_db sysname,
                                              @publisher sysname, @publisher_db sysname,
                                              @subscription_type nvarchar(15), @found int) as
-- missing source code
go

create procedure sys.sp_helpntgroup(@ntname sysname) as
-- missing source code
go

create procedure sys.sp_helppeerrequests(@publication sysname, @description nvarchar(4000)) as
-- missing source code
go

create procedure sys.sp_helppeerresponses(@request_id int) as
-- missing source code
go

create procedure sys.sp_helppublication(@publication sysname, @found int, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_helppublication_snapshot(@publication sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_helppublicationsync(@publication sysname) as
-- missing source code
go

create procedure sys.sp_helppullsubscription(@publisher sysname, @publisher_db sysname, @publication sysname,
                                             @show_push nvarchar(5)) as
-- missing source code
go

create procedure sys.sp_helpqreader_agent(@frompublisher bit) as
-- missing source code
go

create procedure sys.sp_helpremotelogin(@remoteserver sysname, @remotename sysname) as
-- missing source code
go

create procedure sys.sp_helpreplfailovermode(@publisher sysname, @publisher_db sysname, @publication sysname,
                                             @failover_mode_id tinyint, @failover_mode nvarchar(10)) as
-- missing source code
go

create procedure sys.sp_helpreplicationdb(@dbname sysname, @type sysname) as
-- missing source code
go

create procedure sys.sp_helpreplicationdboption(@dbname sysname, @type sysname, @reserved bit) as
-- missing source code
go

create procedure sys.sp_helpreplicationoption(@optname sysname) as
-- missing source code
go

create procedure sys.sp_helprole(@rolename sysname) as
-- missing source code
go

create procedure sys.sp_helprolemember(@rolename sysname) as
-- missing source code
go

create procedure sys.sp_helprotect(@name nvarchar(776), @username sysname, @grantorname sysname,
                                   @permissionarea varchar(10)) as
-- missing source code
go

create procedure sys.sp_helpserver(@server sysname, @optname varchar(35), @show_topology varchar) as
-- missing source code
go

create procedure sys.sp_helpsort() as
-- missing source code
go

create procedure sys.sp_helpsrvrole(@srvrolename sysname) as
-- missing source code
go

create procedure sys.sp_helpsrvrolemember(@srvrolename sysname) as
-- missing source code
go

create procedure sys.sp_helpstats(@objname nvarchar(776), @results nvarchar(5)) as
-- missing source code
go

create procedure sys.sp_helpsubscriberinfo(@subscriber sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_helpsubscription(@publication sysname, @article sysname, @subscriber sysname,
                                         @destination_db sysname, @found int, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_helpsubscription_properties(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                    @publication_type int) as
-- missing source code
go

create procedure sys.sp_helpsubscriptionerrors(@publisher sysname, @publisher_db sysname, @publication sysname,
                                               @subscriber sysname, @subscriber_db sysname) as
-- missing source code
go

create procedure sys.sp_helptext(@objname nvarchar(776), @columnname sysname) as
-- missing source code
go

create procedure sys.sp_helptracertokenhistory(@publication sysname, @tracer_id int, @publisher sysname,
                                               @publisher_db sysname) as
-- missing source code
go

create procedure sys.sp_helptracertokens(@publication sysname, @publisher sysname, @publisher_db sysname) as
-- missing source code
go

create procedure sys.sp_helptrigger(@tabname nvarchar(776), @triggertype char(6)) as
-- missing source code
go

create procedure sys.sp_helpuser(@name_in_db sysname) as
-- missing source code
go

create procedure sys.sp_helpxactsetjob(@publisher sysname) as
-- missing source code
go

create procedure sys.sp_http_generate_wsdl_complex() as
-- missing source code
go

create procedure sys.sp_http_generate_wsdl_defaultcomplexorsimple(@EndpointID int, @IsSSL bit, @Host nvarchar(256),
                                                                  @QueryString nvarchar(256),
                                                                  @UserAgent nvarchar(256)) as
-- missing source code
go

create procedure sys.sp_http_generate_wsdl_defaultsimpleorcomplex(@EndpointID int, @IsSSL bit, @Host nvarchar(256),
                                                                  @QueryString nvarchar(256),
                                                                  @UserAgent nvarchar(256)) as
-- missing source code
go

create procedure sys.sp_http_generate_wsdl_simple() as
-- missing source code
go

create procedure sys.sp_identitycolumnforreplication(@object_id int, @value bit) as
-- missing source code
go

create procedure sys.sp_indexcolumns_managed(@Catalog sysname, @Owner sysname, @Table sysname, @ConstraintName sysname,
                                             @Column sysname) as
-- missing source code
go

create procedure sys.sp_indexes(@table_server sysname, @table_name sysname, @table_schema sysname,
                                @table_catalog sysname, @index_name sysname, @is_unique bit) as
-- missing source code
go

create procedure sys.sp_indexes_100_rowset(@table_name sysname, @index_name sysname, @table_schema sysname) as
-- missing source code
go

create procedure sys.sp_indexes_100_rowset2(@index_name sysname, @table_schema sysname) as
-- missing source code
go

create procedure sys.sp_indexes_90_rowset(@table_name sysname, @index_name sysname, @table_schema sysname) as
-- missing source code
go

create procedure sys.sp_indexes_90_rowset2(@index_name sysname, @table_schema sysname) as
-- missing source code
go

create procedure sys.sp_indexes_90_rowset_rmt(@table_server sysname, @table_catalog sysname, @table_name sysname,
                                              @index_name sysname, @table_schema sysname) as
-- missing source code
go

create procedure sys.sp_indexes_managed(@Catalog sysname, @Owner sysname, @Table sysname, @Name sysname) as
-- missing source code
go

create procedure sys.sp_indexes_rowset(@table_name sysname, @index_name sysname, @table_schema sysname) as
-- missing source code
go

create procedure sys.sp_indexes_rowset2(@index_name sysname, @table_schema sysname) as
-- missing source code
go

create procedure sys.sp_indexes_rowset_rmt(@table_server sysname, @table_catalog sysname, @table_name sysname,
                                           @index_name sysname, @table_schema sysname) as
-- missing source code
go

create procedure sys.sp_indexoption(@IndexNamePattern nvarchar(1035), @OptionName varchar(35),
                                    @OptionValue varchar(12)) as
-- missing source code
go

create procedure sys.sp_internal_alter_nt_job_limits() as
-- missing source code
go

create procedure sys.sp_invalidate_textptr(@TextPtrValue varbinary(16)) as
-- missing source code
go

create procedure sys.sp_invoke_external_rest_endpoint(@url nvarchar(4000), @payload nvarchar(max),
                                                      @headers nvarchar(4000), @method nvarchar(6), @timeout smallint,
                                                      @credential sysname, @response nvarchar(max)) as
-- missing source code
go

create procedure sys.sp_is_columnstore_column_dictionary_enabled(@table_id int, @column_id int, @is_enabled bit) as
-- missing source code
go

create procedure sys.sp_is_makegeneration_needed(@wait int, @needed int) as
-- missing source code
go

create procedure sys.sp_ivindexhasnullcols(@viewname sysname, @fhasnullcols bit) as
-- missing source code
go

create procedure sys.sp_kill_filestream_non_transacted_handles(@table_name nvarchar(776), @handle_id int) as
-- missing source code
go

create procedure sys.sp_kill_oldest_transaction_on_secondary(@database_name sysname, @kill_all bit, @killed_xdests bigint) as
-- missing source code
go

create procedure sys.sp_ldw_apply_file_updates_for_ext_table(@ext_table_name sysname, @files_delta_table_name sysname,
                                                             @containers_delta_table_name sysname,
                                                             @partitions_delta_table_name sysname,
                                                             @curr_max_generation_id bigint, @token nvarchar(4000)) as
-- missing source code
go

create procedure sys.sp_ldw_get_file_updates_for_ext_table(@ext_table_name sysname, @datasource_name nvarchar(128),
                                                           @enumeration_root nvarchar(4000),
                                                           @files_delta_table_name sysname,
                                                           @containers_delta_table_name sysname,
                                                           @partitions_delta_table_name sysname,
                                                           @token nvarchar(4000)) as
-- missing source code
go

create procedure sys.sp_ldw_insert_container_and_partition_for_ext_table(@ext_table_name sysname,
                                                                         @location nvarchar(4000),
                                                                         @part_key_name nvarchar(4000),
                                                                         @part_key_val nvarchar(4000)) as
-- missing source code
go

create procedure sys.sp_ldw_internal_tables_clean_up(@ext_table_name sysname) as
-- missing source code
go

create procedure sys.sp_ldw_normalize_ext_tab_name(@ext_table_name sysname, @quoted_two_part_name sysname,
                                                   @object_id int) as
-- missing source code
go

create procedure sys.sp_ldw_refresh_internal_table_on_distribution(@ext_table_name sysname, @staging_table_name sysname,
                                                                   @internal_table_name sysname) as
-- missing source code
go

create procedure sys.sp_ldw_select_entries_from_internal_table(@ext_table_name sysname, @internal_table_name sysname,
                                                               @distributed_move_paramaters nvarchar(max)) as
-- missing source code
go

create procedure sys.sp_ldw_update_stats_for_ext_table(@ext_table_name sysname) as
-- missing source code
go

create procedure sys.sp_lightweightmergemetadataretentioncleanup(@num_rowtrack_rows int) as
-- missing source code
go

create procedure sys.sp_link_publication(@publisher sysname, @publisher_db sysname, @publication sysname,
                                         @security_mode int, @login sysname, @password sysname, @distributor sysname) as
-- missing source code
go

create procedure sys.sp_linkedservers() as
-- missing source code
go

create procedure sys.sp_linkedservers_rowset(@srvname sysname) as
-- missing source code
go

create procedure sys.sp_linkedservers_rowset2() as
-- missing source code
go

create procedure sys.sp_lock(@spid1 int, @spid2 int) as
-- missing source code
go

create procedure sys.sp_logshippinginstallmetadata() as
-- missing source code
go

create procedure sys.sp_lookupcustomresolver(@article_resolver nvarchar(255), @resolver_clsid nvarchar(50),
                                             @is_dotnet_assembly bit, @dotnet_assembly_name nvarchar(255),
                                             @dotnet_class_name nvarchar(255), @publisher sysname) as
-- missing source code
go

create procedure sys.sp_manage_distributed_transaction() as
-- missing source code
go

create procedure sys.sp_mapdown_bitmap(@mapdownbm varbinary(128), @bm varbinary(128)) as
-- missing source code
go

create procedure sys.sp_markpendingschemachange(@publication sysname, @schemaversion int, @status nvarchar(10)) as
-- missing source code
go

create procedure sys.sp_marksubscriptionvalidation(@publication sysname, @subscriber sysname, @destination_db sysname,
                                                   @publisher sysname) as
-- missing source code
go

create procedure sys.sp_md_discovery_stats_staleness_detection() as
-- missing source code
go

create procedure sys.sp_memory_leak_detection(@leakThresholdPercent float, @timeToLookbackMinutes int,
                                              @intervalSeconds int, @maxRecords int, @clerkType varchar(256),
                                              @clerkName varchar(256)) as
-- missing source code
go

create procedure sys.sp_memory_optimized_cs_migration(@object_id int) as
-- missing source code
go

create procedure sys.sp_mergearticlecolumn(@publication sysname, @article sysname, @column sysname,
                                           @operation nvarchar(4), @schema_replication nvarchar(5),
                                           @force_invalidate_snapshot bit, @force_reinit_subscription bit) as
-- missing source code
go

create procedure sys.sp_mergecleanupmetadata(@publication sysname, @reinitialize_subscriber nvarchar(5)) as
-- missing source code
go

create procedure sys.sp_mergedummyupdate(@source_object nvarchar(386), @rowguid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_mergemetadataretentioncleanup(@num_genhistory_rows int, @num_contents_rows int,
                                                      @num_tombstone_rows int, @aggressive_cleanup_only bit) as
-- missing source code
go

create procedure sys.sp_mergesubscription_cleanup(@publisher sysname, @publisher_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_mergesubscriptionsummary(@publication sysname, @subscriber sysname, @subscriber_db sysname) as
-- missing source code
go

create procedure sys.sp_metadata_sync_connector_add(@unique_name varchar(max), @type varchar(20),
                                                    @jdbc_connection_url nvarchar(max), @driver_name nvarchar(max),
                                                    @username nvarchar(max), @password nvarchar(max),
                                                    @max_retry_count tinyint, @retry_interval_ms int,
                                                    @sql_command_timeout_sec smallint, @sync_interval_sec smallint,
                                                    @mappings_json nvarchar(max)) as
-- missing source code
go

create procedure sys.sp_metadata_sync_connector_drop(@unique_name varchar(max)) as
-- missing source code
go

create procedure sys.sp_metadata_sync_connectors_status(@unique_name varchar(max)) as
-- missing source code
go

create procedure sys.sp_migrate_user_to_contained() as
-- missing source code
go

create procedure sys.sp_monitor() as
-- missing source code
go

create procedure sys.sp_new_parallel_nested_tran_id() as
-- missing source code
go

create procedure sys.sp_objectfilegroup(@objid int) as
-- missing source code
go

create procedure sys.sp_oledb_database() as
-- missing source code
go

create procedure sys.sp_oledb_defdb() as
-- missing source code
go

create procedure sys.sp_oledb_deflang() as
-- missing source code
go

create procedure sys.sp_oledb_language() as
-- missing source code
go

create procedure sys.sp_oledb_ro_usrname() as
-- missing source code
go

create procedure sys.sp_oledbinfo(@server nvarchar(128), @infotype nvarchar(128), @login nvarchar(128),
                                  @password nvarchar(128)) as
-- missing source code
go

create procedure sys.sp_password(@old sysname, @new sysname, @loginame sysname) as
-- missing source code
go

create procedure sys.sp_peerconflictdetection_tableaug(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                       @enabling bit, @originator_id int, @artlist nvarchar(max),
                                                       @conflictdetection_policy nvarchar(12)) as
-- missing source code
go

create procedure sys.sp_persistent_version_cleanup(@dbname sysname, @scanallpages bit, @clean_option int) as
-- missing source code
go

create procedure sys.sp_pkeys(@table_name sysname, @table_owner sysname, @table_qualifier sysname) as
-- missing source code
go

create procedure sys.sp_polybase_authorize() as
-- missing source code
go

create procedure sys.sp_polybase_join_group() as
-- missing source code
go

create procedure sys.sp_polybase_leave_group() as
-- missing source code
go

create procedure sys.sp_polybase_show_objects() as
-- missing source code
go

create procedure sys.sp_posttracertoken(@publication sysname, @tracer_token_id int, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_prepare() as
-- missing source code
go

create procedure sys.sp_prepexec() as
-- missing source code
go

create procedure sys.sp_prepexecrpc() as
-- missing source code
go

create procedure sys.sp_primary_keys_rowset(@table_name sysname, @table_schema sysname) as
-- missing source code
go

create procedure sys.sp_primary_keys_rowset2(@table_schema sysname) as
-- missing source code
go

create procedure sys.sp_primary_keys_rowset_rmt(@table_server sysname, @table_catalog sysname, @table_name sysname,
                                                @table_schema sysname) as
-- missing source code
go

create procedure sys.sp_primarykeys(@table_server sysname, @table_name sysname, @table_schema sysname,
                                    @table_catalog sysname) as
-- missing source code
go

create procedure sys.sp_procedure_params_100_managed(@procedure_name sysname, @group_number int,
                                                     @procedure_schema sysname, @parameter_name sysname) as
-- missing source code
go

create procedure sys.sp_procedure_params_100_rowset(@procedure_name sysname, @group_number int,
                                                    @procedure_schema sysname, @parameter_name sysname) as
-- missing source code
go

create procedure sys.sp_procedure_params_100_rowset2(@procedure_schema sysname, @parameter_name sysname) as
-- missing source code
go

create procedure sys.sp_procedure_params_90_rowset(@procedure_name sysname, @group_number int,
                                                   @procedure_schema sysname, @parameter_name sysname) as
-- missing source code
go

create procedure sys.sp_procedure_params_90_rowset2(@procedure_schema sysname, @parameter_name sysname) as
-- missing source code
go

create procedure sys.sp_procedure_params_managed(@procedure_name sysname, @group_number int, @procedure_schema sysname,
                                                 @parameter_name sysname) as
-- missing source code
go

create procedure sys.sp_procedure_params_rowset(@procedure_name sysname, @group_number int, @procedure_schema sysname,
                                                @parameter_name sysname) as
-- missing source code
go

create procedure sys.sp_procedure_params_rowset2(@procedure_schema sysname, @parameter_name sysname) as
-- missing source code
go

create procedure sys.sp_procedures_rowset(@procedure_name sysname, @group_number int, @procedure_schema sysname) as
-- missing source code
go

create procedure sys.sp_procedures_rowset2(@procedure_schema sysname) as
-- missing source code
go

create procedure sys.sp_process_memory_leak_record() as
-- missing source code
go

create procedure sys.sp_processlogshippingmonitorhistory(@mode tinyint, @agent_id uniqueidentifier, @agent_type tinyint,
                                                         @session_id int, @session_status tinyint,
                                                         @monitor_server sysname, @monitor_server_security_mode bit,
                                                         @database sysname, @log_time datetime, @log_time_utc datetime,
                                                         @message nvarchar(4000)) as
-- missing source code
go

create procedure sys.sp_processlogshippingmonitorprimary(@mode tinyint, @primary_id uniqueidentifier,
                                                         @primary_server sysname, @monitor_server sysname,
                                                         @monitor_server_security_mode bit, @primary_database sysname,
                                                         @backup_threshold int, @threshold_alert int,
                                                         @threshold_alert_enabled bit, @last_backup_file nvarchar(500),
                                                         @last_backup_date datetime, @last_backup_date_utc datetime,
                                                         @history_retention_period int) as
-- missing source code
go

create procedure sys.sp_processlogshippingmonitorsecondary(@mode tinyint, @secondary_server sysname,
                                                           @secondary_database sysname, @secondary_id uniqueidentifier,
                                                           @primary_server sysname, @monitor_server sysname,
                                                           @monitor_server_security_mode bit, @primary_database sysname,
                                                           @restore_threshold int, @threshold_alert int,
                                                           @threshold_alert_enabled bit,
                                                           @last_copied_file nvarchar(500), @last_copied_date datetime,
                                                           @last_copied_date_utc datetime,
                                                           @last_restored_file nvarchar(500),
                                                           @last_restored_date datetime,
                                                           @last_restored_date_utc datetime, @last_restored_latency int,
                                                           @history_retention_period int) as
-- missing source code
go

create procedure sys.sp_processlogshippingretentioncleanup(@agent_id uniqueidentifier, @agent_type tinyint,
                                                           @monitor_server sysname, @monitor_server_security_mode bit,
                                                           @history_retention_period int, @curdate_utc datetime) as
-- missing source code
go

create procedure sys.sp_procoption(@ProcName nvarchar(776), @OptionName varchar(35), @OptionValue varchar(12)) as
-- missing source code
go

create procedure sys.sp_prop_oledb_provider(@p1 nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_provider_types_100_rowset(@data_type smallint, @best_match tinyint) as
-- missing source code
go

create procedure sys.sp_provider_types_90_rowset(@data_type smallint, @best_match tinyint) as
-- missing source code
go

create procedure sys.sp_provider_types_rowset(@data_type smallint, @best_match tinyint) as
-- missing source code
go

create procedure sys.sp_publication_validation(@publication sysname, @rowcount_only smallint, @full_or_fast tinyint,
                                               @shutdown_agent bit, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_publicationsummary(@publication sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_publish_database_to_syms() as
-- missing source code
go

create procedure sys.sp_publishdb(@dbname sysname, @value nvarchar(5)) as
-- missing source code
go

create procedure sys.sp_publisherproperty(@publisher sysname, @propertyname sysname, @propertyvalue sysname) as
-- missing source code
go

create procedure sys.sp_query_store_clear_hints() as
-- missing source code
go

create procedure sys.sp_query_store_clear_message_queues() as
-- missing source code
go

create procedure sys.sp_query_store_consistency_check() as
-- missing source code
go

create procedure sys.sp_query_store_flush_db() as
-- missing source code
go

create procedure sys.sp_query_store_force_plan() as
-- missing source code
go

create procedure sys.sp_query_store_remove_plan() as
-- missing source code
go

create procedure sys.sp_query_store_remove_query() as
-- missing source code
go

create procedure sys.sp_query_store_reset_exec_stats() as
-- missing source code
go

create procedure sys.sp_query_store_set_hints() as
-- missing source code
go

create procedure sys.sp_query_store_unforce_plan() as
-- missing source code
go

create procedure sys.sp_rbpex_exec_cmd() as
-- missing source code
go

create procedure sys.sp_rda_deauthorize_db() as
-- missing source code
go

create procedure sys.sp_rda_get_rpo_duration() as
-- missing source code
go

create procedure sys.sp_rda_reauthorize_db() as
-- missing source code
go

create procedure sys.sp_rda_reconcile_batch() as
-- missing source code
go

create procedure sys.sp_rda_reconcile_columns() as
-- missing source code
go

create procedure sys.sp_rda_reconcile_indexes() as
-- missing source code
go

create procedure sys.sp_rda_set_query_mode() as
-- missing source code
go

create procedure sys.sp_rda_set_rpo_duration() as
-- missing source code
go

create procedure sys.sp_rda_test_connection() as
-- missing source code
go

create procedure sys.sp_readerrorlog(@p1 int, @p2 int, @p3 nvarchar(4000), @p4 nvarchar(4000)) as
-- missing source code
go

create procedure sys.sp_recompile(@objname nvarchar(776)) as
-- missing source code
go

create procedure sys.sp_redirect_publisher(@original_publisher sysname, @publisher_db sysname,
                                           @redirected_publisher sysname) as
-- missing source code
go

create procedure sys.sp_refresh_heterogeneous_publisher(@publisher sysname) as
-- missing source code
go

create procedure sys.sp_refresh_log_shipping_monitor(@agent_id uniqueidentifier, @agent_type tinyint, @database sysname,
                                                     @mode tinyint) as
-- missing source code
go

create procedure sys.sp_refresh_parameter_encryption(@name nvarchar(776), @namespace nvarchar(20)) as
-- missing source code
go

create procedure sys.sp_refresh_single_snapshot_view(@view_name nvarchar(261), @rgCode int) as
-- missing source code
go

create procedure sys.sp_refresh_snapshot_views(@rgCode int) as
-- missing source code
go

create procedure sys.sp_refreshsqlmodule(@name nvarchar(776), @namespace nvarchar(20)) as
-- missing source code
go

create procedure sys.sp_refreshsubscriptions(@publication sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_refreshview(@viewname nvarchar(776)) as
-- missing source code
go

create procedure sys.sp_register_custom_scripting(@type varchar(16), @value nvarchar(2048), @publication sysname,
                                                  @article sysname) as
-- missing source code
go

create procedure sys.sp_registercustomresolver(@article_resolver nvarchar(255), @resolver_clsid nvarchar(50),
                                               @is_dotnet_assembly nvarchar(10), @dotnet_assembly_name nvarchar(255),
                                               @dotnet_class_name nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_reinitmergepullsubscription(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                    @upload_first nvarchar(5)) as
-- missing source code
go

create procedure sys.sp_reinitmergesubscription(@publication sysname, @subscriber sysname, @subscriber_db sysname,
                                                @upload_first nvarchar(5)) as
-- missing source code
go

create procedure sys.sp_reinitpullsubscription(@publisher sysname, @publisher_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_reinitsubscription(@publication sysname, @article sysname, @subscriber sysname,
                                           @destination_db sysname, @for_schema_change bit, @publisher sysname,
                                           @ignore_distributor_failure bit, @invalidate_snapshot bit) as
-- missing source code
go

create procedure sys.sp_release_all_fido_locks() as
-- missing source code
go

create procedure sys.sp_release_fido_lock() as
-- missing source code
go

create procedure sys.sp_releaseapplock(@Resource nvarchar(255), @LockOwner varchar(32), @DbPrincipal sysname) as
-- missing source code
go

create procedure sys.sp_releaseschemalock() as
-- missing source code
go

create procedure sys.sp_remote_data_archive_event() as
-- missing source code
go

create procedure sys.sp_remoteoption(@remoteserver sysname, @loginame sysname, @remotename sysname,
                                     @optname varchar(35), @optvalue varchar(10)) as
-- missing source code
go

create procedure sys.sp_remove_columnstore_column_dictionary(@table_id int, @column_id int) as
-- missing source code
go

create procedure sys.sp_removedbreplication(@dbname sysname, @type nvarchar(5)) as
-- missing source code
go

create procedure sys.sp_removedistpublisherdbreplication(@publisher sysname, @publisher_db sysname) as
-- missing source code
go

create procedure sys.sp_removesrvreplication() as
-- missing source code
go

create procedure sys.sp_rename(@objname nvarchar(1035), @newname sysname, @objtype varchar(13)) as
-- missing source code
go

create procedure sys.sp_renamedb(@dbname sysname, @newname sysname) as
-- missing source code
go

create procedure sys.sp_repl_generate_subscriber_event() as
-- missing source code
go

create procedure sys.sp_repl_generate_sync_status_event() as
-- missing source code
go

create procedure sys.sp_repl_generateevent() as
-- missing source code
go

create procedure sys.sp_repladdcolumn(@source_object nvarchar(358), @column sysname, @typetext nvarchar(3000),
                                      @publication_to_add nvarchar(4000), @from_agent int,
                                      @schema_change_script nvarchar(4000), @force_invalidate_snapshot bit,
                                      @force_reinit_subscription bit) as
-- missing source code
go

create procedure sys.sp_replcleanupccsprocs(@publication sysname) as
-- missing source code
go

create procedure sys.sp_replcmds() as
-- missing source code
go

create procedure sys.sp_replcounters() as
-- missing source code
go

create procedure sys.sp_replddlparser() as
-- missing source code
go

create procedure sys.sp_repldeletequeuedtran(@publisher sysname, @publisher_db sysname, @publication sysname,
                                             @tranid sysname, @orderkeylow bigint, @orderkeyhigh bigint) as
-- missing source code
go

create procedure sys.sp_repldone() as
-- missing source code
go

create procedure sys.sp_repldropcolumn(@source_object nvarchar(270), @column sysname, @from_agent int,
                                       @schema_change_script nvarchar(4000), @force_invalidate_snapshot bit,
                                       @force_reinit_subscription bit) as
-- missing source code
go

create procedure sys.sp_replflush() as
-- missing source code
go

create procedure sys.sp_replgetparsedddlcmd(@ddlcmd nvarchar(max), @FirstToken sysname, @objectType sysname,
                                            @dbname sysname, @owner sysname, @objname sysname,
                                            @targetobject nvarchar(512)) as
-- missing source code
go

create procedure sys.sp_replhelp() as
-- missing source code
go

create procedure sys.sp_replica(@tabname nvarchar(92), @replicated nvarchar(5)) as
-- missing source code
go

create procedure sys.sp_replication_agent_checkup(@heartbeat_interval int) as
-- missing source code
go

create procedure sys.sp_replicationdboption(@dbname sysname, @optname sysname, @value sysname, @ignore_distributor bit,
                                            @from_scripting bit) as
-- missing source code
go

create procedure sys.sp_replincrementlsn(@xact_seqno binary(10), @publisher sysname) as
-- missing source code
go

create procedure sys.sp_replmonitorchangepublicationthreshold(@publisher sysname, @publisher_db sysname,
                                                              @publication sysname, @publication_type int,
                                                              @metric_id int, @thresholdmetricname sysname, @value int,
                                                              @shouldalert bit, @mode tinyint) as
-- missing source code
go

create procedure sys.sp_replmonitorgetoriginalpublisher(@publisher sysname, @orig_publisher sysname) as
-- missing source code
go

create procedure sys.sp_replmonitorhelpmergesession(@agent_name nvarchar(100), @hours int, @session_type int,
                                                    @publisher sysname, @publisher_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_replmonitorhelpmergesessiondetail(@session_id int) as
-- missing source code
go

create procedure sys.sp_replmonitorhelpmergesubscriptionmoreinfo(@publisher sysname, @publisher_db sysname,
                                                                 @publication sysname, @subscriber sysname,
                                                                 @subscriber_db sysname) as
-- missing source code
go

create procedure sys.sp_replmonitorhelppublication(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                   @publication_type int, @refreshpolicy tinyint) as
-- missing source code
go

create procedure sys.sp_replmonitorhelppublicationthresholds(@publisher sysname, @publisher_db sysname,
                                                             @publication sysname, @publication_type int,
                                                             @thresholdmetricname sysname) as
-- missing source code
go

create procedure sys.sp_replmonitorhelppublisher(@publisher sysname, @refreshpolicy tinyint) as
-- missing source code
go

create procedure sys.sp_replmonitorhelpsubscription(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                    @publication_type int, @mode int, @topnum int,
                                                    @exclude_anonymous bit, @refreshpolicy tinyint) as
-- missing source code
go

create procedure sys.sp_replmonitorrefreshjob(@iterations tinyint, @profile bit) as
-- missing source code
go

create procedure sys.sp_replmonitorsubscriptionpendingcmds(@publisher sysname, @publisher_db sysname,
                                                           @publication sysname, @subscriber sysname,
                                                           @subscriber_db sysname, @subscription_type int,
                                                           @subdb_version int) as
-- missing source code
go

create procedure sys.sp_replpostsyncstatus(@pubid int, @artid int, @syncstat int, @xact_seqno binary(10)) as
-- missing source code
go

create procedure sys.sp_replqueuemonitor(@publisher sysname, @publisherdb sysname, @publication sysname,
                                         @tranid sysname, @queuetype tinyint) as
-- missing source code
go

create procedure sys.sp_replrestart() as
-- missing source code
go

create procedure sys.sp_replrethrow() as
-- missing source code
go

create procedure sys.sp_replsendtoqueue() as
-- missing source code
go

create procedure sys.sp_replsetoriginator(@originator_srv sysname, @originator_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_replsetsyncstatus() as
-- missing source code
go

create procedure sys.sp_replshowcmds(@maxtrans int) as
-- missing source code
go

create procedure sys.sp_replsqlqgetrows(@publisher sysname, @publisherdb sysname, @publication sysname,
                                        @batchsize int) as
-- missing source code
go

create procedure sys.sp_replsync(@publisher sysname, @publisher_db sysname, @publication sysname, @article sysname) as
-- missing source code
go

create procedure sys.sp_repltrans() as
-- missing source code
go

create procedure sys.sp_replwritetovarbin() as
-- missing source code
go

create procedure sys.sp_requestpeerresponse(@publication sysname, @description nvarchar(4000), @request_id int) as
-- missing source code
go

create procedure sys.sp_requestpeertopologyinfo(@publication sysname, @request_id int) as
-- missing source code
go

create procedure sys.sp_reserve_http_namespace() as
-- missing source code
go

create procedure sys.sp_reset_connection() as
-- missing source code
go

create procedure sys.sp_reset_dtc_log() as
-- missing source code
go

create procedure sys.sp_reset_inactive_duration_flag() as
-- missing source code
go

create procedure sys.sp_reset_session_context() as
-- missing source code
go

create procedure sys.sp_resetsnapshotdeliveryprogress(@verbose_level int, @drop_table nvarchar(5)) as
-- missing source code
go

create procedure sys.sp_resetstatus(@DBName sysname) as
-- missing source code
go

create procedure sys.sp_resign_database(@keytype sysname, @fn nvarchar(512), @pwd sysname) as
-- missing source code
go

create procedure sys.sp_resolve_logins(@dest_db sysname, @dest_path nvarchar(255), @filename nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_restore_filelistonly(@device_type nvarchar(10), @backup_path nvarchar(360)) as
-- missing source code
go

create procedure sys.sp_restoredbreplication(@srv_orig sysname, @db_orig sysname, @keep_replication int,
                                             @perform_upgrade bit, @recoveryforklsn varbinary(16)) as
-- missing source code
go

create procedure sys.sp_restoremergeidentityrange(@publication sysname, @article sysname) as
-- missing source code
go

create procedure sys.sp_resyncexecute() as
-- missing source code
go

create procedure sys.sp_resyncexecutesql() as
-- missing source code
go

create procedure sys.sp_resyncmergesubscription(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                @subscriber sysname, @subscriber_db sysname, @resync_type int,
                                                @resync_date_str nvarchar(30)) as
-- missing source code
go

create procedure sys.sp_resyncprepare() as
-- missing source code
go

create procedure sys.sp_resyncuniquetable() as
-- missing source code
go

create procedure sys.sp_revoke_publication_access(@publication sysname, @login sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_revokedbaccess(@name_in_db sysname) as
-- missing source code
go

create procedure sys.sp_revokelogin(@loginame sysname) as
-- missing source code
go

create procedure sys.sp_rollback_parallel_nested_tran() as
-- missing source code
go

create procedure sys.sp_schemafilter(@publisher sysname, @schema sysname, @operation nvarchar(4)) as
-- missing source code
go

create procedure sys.sp_schemata_rowset(@schema_name sysname, @schema_owner sysname) as
-- missing source code
go

create procedure sys.sp_script_reconciliation_delproc(@artid int, @publishertype tinyint, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_script_reconciliation_insproc(@artid int, @publishertype tinyint, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_script_reconciliation_sinsproc(@artid int, @publishertype tinyint, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_script_reconciliation_vdelproc(@artid int, @publishertype tinyint, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_script_reconciliation_xdelproc(@artid int, @publishertype tinyint, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_script_synctran_commands(@publication sysname, @article sysname, @trig_only bit,
                                                 @usesqlclr bit) as
-- missing source code
go

create procedure sys.sp_scriptdelproc(@artid int, @publishertype tinyint, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_scriptdynamicupdproc(@artid int) as
-- missing source code
go

create procedure sys.sp_scriptinsproc(@artid int, @publishertype tinyint, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_scriptmappedupdproc(@artid int, @mode tinyint, @publishertype tinyint, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_scriptpublicationcustomprocs(@publication sysname, @publisher sysname, @usesqlclr bit) as
-- missing source code
go

create procedure sys.sp_scriptsinsproc(@artid int, @publishertype tinyint, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_scriptsubconflicttable(@publication sysname, @article sysname, @alter bit, @usesqlclr bit) as
-- missing source code
go

create procedure sys.sp_scriptsupdproc(@artid int, @mode tinyint, @publishertype tinyint, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_scriptupdproc(@artid int, @mode tinyint, @publishertype tinyint, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_scriptvdelproc(@artid int, @publishertype tinyint, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_scriptvupdproc(@artid int, @mode tinyint, @publishertype tinyint, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_scriptxdelproc(@artid int, @publishertype tinyint, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_scriptxupdproc(@artid int, @mode tinyint, @publishertype tinyint, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_sequence_get_range(@sequence_name nvarchar(776), @range_size bigint,
                                           @range_first_value sql_variant, @range_last_value sql_variant,
                                           @range_cycle_count int, @sequence_increment sql_variant,
                                           @sequence_min_value sql_variant, @sequence_max_value sql_variant) as
-- missing source code
go

create procedure sys.sp_server_diagnostics() as
-- missing source code
go

create procedure sys.sp_server_info(@attribute_id int) as
-- missing source code
go

create procedure sys.sp_serveroption(@server sysname, @optname varchar(35), @optvalue nvarchar(128)) as
-- missing source code
go

create procedure sys.sp_setOraclepackageversion(@publisher sysname) as
-- missing source code
go

create procedure sys.sp_set_blob_ringbuffer_memory() as
-- missing source code
go

create procedure sys.sp_set_data_processed_limit() as
-- missing source code
go

create procedure sys.sp_set_database_engine_configuration_internal() as
-- missing source code
go

create procedure sys.sp_set_def_format_type_default_target() as
-- missing source code
go

create procedure sys.sp_set_def_format_type_extractor() as
-- missing source code
go

create procedure sys.sp_set_def_format_type_md_preprocessor() as
-- missing source code
go

create procedure sys.sp_set_distributed_feedback_context() as
-- missing source code
go

create procedure sys.sp_set_distributed_query_context() as
-- missing source code
go

create procedure sys.sp_set_format_type_ls_syntax() as
-- missing source code
go

create procedure sys.sp_set_msdtc_network() as
-- missing source code
go

create procedure sys.sp_set_parser_version_default_target() as
-- missing source code
go

create procedure sys.sp_set_parser_version_extractor() as
-- missing source code
go

create procedure sys.sp_set_parser_version_md_preprocessor() as
-- missing source code
go

create procedure sys.sp_set_session_context() as
-- missing source code
go

create procedure sys.sp_set_session_resource_group() as
-- missing source code
go

create procedure sys.sp_set_trident_data_location(@storagePath nvarchar(2000)) as
-- missing source code
go

create procedure sys.sp_setapprole(@rolename sysname, @password sysname, @encrypt varchar(10), @fCreateCookie bit,
                                   @cookie varbinary(8000)) as
-- missing source code
go

create procedure sys.sp_setdefaultdatatypemapping(@mapping_id int, @source_dbms sysname, @source_version varchar(10),
                                                  @source_type sysname, @source_length_min bigint,
                                                  @source_length_max bigint, @source_precision_min bigint,
                                                  @source_precision_max bigint, @source_scale_min int,
                                                  @source_scale_max int, @source_nullable bit,
                                                  @destination_dbms sysname, @destination_version varchar(10),
                                                  @destination_type sysname, @destination_length bigint,
                                                  @destination_precision bigint, @destination_scale int,
                                                  @destination_nullable bit) as
-- missing source code
go

create procedure sys.sp_setnetname(@server sysname, @netname sysname) as
-- missing source code
go

create procedure sys.sp_setreplfailovermode(@publisher sysname, @publisher_db sysname, @publication sysname,
                                            @failover_mode nvarchar(10), @override tinyint) as
-- missing source code
go

create procedure sys.sp_setsubscriptionxactseqno(@publisher sysname, @publisher_db sysname, @publication sysname,
                                                 @xact_seqno varbinary(16)) as
-- missing source code
go

create procedure sys.sp_settriggerorder(@triggername nvarchar(517), @order varchar(10), @stmttype varchar(50),
                                        @namespace varchar(10)) as
-- missing source code
go

create procedure sys.sp_setuserbylogin() as
-- missing source code
go

create procedure sys.sp_show_external_table_average_column_length_statistics() as
-- missing source code
go

create procedure sys.sp_show_openrowset_statistics() as
-- missing source code
go

create procedure sys.sp_showcolv(@colv varbinary(2953)) as
-- missing source code
go

create procedure sys.sp_showinitialmemo_xml() as
-- missing source code
go

create procedure sys.sp_showlineage(@lineage varbinary(311)) as
-- missing source code
go

create procedure sys.sp_showmemo_xml() as
-- missing source code
go

create procedure sys.sp_showpendingchanges(@destination_server sysname, @publication sysname, @article sysname,
                                           @show_rows int) as
-- missing source code
go

create procedure sys.sp_showrowreplicainfo(@ownername sysname, @tablename sysname, @rowguid uniqueidentifier,
                                           @show nvarchar(20)) as
-- missing source code
go

create procedure sys.sp_shutdown_feedback_client_connection() as
-- missing source code
go

create procedure sys.sp_sm_detach() as
-- missing source code
go

create procedure sys.sp_spaceused(@objname nvarchar(776), @updateusage varchar(5), @mode varchar(11), @oneresultset bit,
                                  @include_total_xtp_storage bit) as
-- missing source code
go

create procedure sys.sp_spaceused_remote_data_archive() as
-- missing source code
go

create procedure sys.sp_sparse_columns_100_rowset(@table_name sysname, @table_schema sysname, @column_name sysname,
                                                  @schema_type int) as
-- missing source code
go

create procedure sys.sp_special_columns(@table_name sysname, @table_owner sysname, @table_qualifier sysname,
                                        @col_type char, @scope char, @nullable char, @ODBCVer int) as
-- missing source code
go

create procedure sys.sp_special_columns_100(@table_name sysname, @table_owner sysname, @table_qualifier sysname,
                                            @col_type char, @scope char, @nullable char, @ODBCVer int) as
-- missing source code
go

create procedure sys.sp_special_columns_90(@table_name sysname, @table_owner sysname, @table_qualifier sysname,
                                           @col_type char, @scope char, @nullable char, @ODBCVer int) as
-- missing source code
go

create procedure sys.sp_sproc_columns(@procedure_name nvarchar(390), @procedure_owner nvarchar(384),
                                      @procedure_qualifier sysname, @column_name nvarchar(384), @ODBCVer int,
                                      @fUsePattern bit) as
-- missing source code
go

create procedure sys.sp_sproc_columns_100(@procedure_name nvarchar(390), @procedure_owner nvarchar(384),
                                          @procedure_qualifier sysname, @column_name nvarchar(384), @ODBCVer int,
                                          @fUsePattern bit) as
-- missing source code
go

create procedure sys.sp_sproc_columns_90(@procedure_name nvarchar(390), @procedure_owner nvarchar(384),
                                         @procedure_qualifier sysname, @column_name nvarchar(384), @ODBCVer int,
                                         @fUsePattern bit) as
-- missing source code
go

create procedure sys.sp_sqlagent_add_job(@job_name sysname, @enabled tinyint, @description nvarchar(512),
                                         @start_step_id int, @notify_level_eventlog int, @delete_level int,
                                         @job_id uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_sqlagent_add_jobstep(@job_id uniqueidentifier, @job_name sysname, @step_id int,
                                             @step_name sysname, @subsystem nvarchar(40), @command nvarchar(max),
                                             @additional_parameters nvarchar(max), @cmdexec_success_code int,
                                             @on_success_action tinyint, @on_success_step_id int,
                                             @on_fail_action tinyint, @on_fail_step_id int, @server sysname,
                                             @database_name sysname, @database_user_name sysname, @retry_attempts int,
                                             @retry_interval int, @os_run_priority int, @output_file_name nvarchar(200),
                                             @flags int, @step_uid uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_sqlagent_delete_job(@job_id uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_sqlagent_help_jobstep(@job_id uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_sqlagent_log_job_history(@job_id uniqueidentifier, @step_id int, @sql_message_id int,
                                                 @sql_severity int, @message nvarchar(4000), @run_status int,
                                                 @run_date int, @run_time int, @run_duration int,
                                                 @operator_id_emailed int, @operator_id_paged int,
                                                 @retries_attempted int) as
-- missing source code
go

create procedure sys.sp_sqlagent_start_job(@job_id uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_sqlagent_stop_job(@job_id uniqueidentifier) as
-- missing source code
go

create procedure sys.sp_sqlagent_verify_database_context() as
-- missing source code
go

create procedure sys.sp_sqlagent_write_jobstep_log(@job_id uniqueidentifier, @step_id int, @log_text nvarchar(max)) as
-- missing source code
go

create procedure sys.sp_sqlexec(@p1 text) as
-- missing source code
go

create procedure sys.sp_srvrolepermission(@srvrolename sysname) as
-- missing source code
go

create procedure sys.sp_start_fixed_vlf() as
-- missing source code
go

create procedure sys.sp_start_flight_server() as
-- missing source code
go

create procedure sys.sp_start_glm_server() as
-- missing source code
go

create procedure sys.sp_start_streaming_job(@name sysname, @resources nvarchar(255), @outputStartTime nvarchar(255),
                                            @testMode nvarchar(50)) as
-- missing source code
go

create procedure sys.sp_start_user_instance() as
-- missing source code
go

create procedure sys.sp_startmergepullsubscription_agent(@publisher sysname, @publisher_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_startmergepushsubscription_agent(@publication sysname, @subscriber sysname, @subscriber_db sysname) as
-- missing source code
go

create procedure sys.sp_startpublication_snapshot(@publication sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_startpullsubscription_agent(@publisher sysname, @publisher_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_startpushsubscription_agent(@publication sysname, @subscriber sysname, @subscriber_db sysname,
                                                    @publisher sysname) as
-- missing source code
go

create procedure sys.sp_statistics(@table_name sysname, @table_owner sysname, @table_qualifier sysname,
                                   @index_name sysname, @is_unique char, @accuracy char) as
-- missing source code
go

create procedure sys.sp_statistics_100(@table_name sysname, @table_owner sysname, @table_qualifier sysname,
                                       @index_name sysname, @is_unique char, @accuracy char) as
-- missing source code
go

create procedure sys.sp_statistics_rowset(@table_name sysname, @table_schema sysname) as
-- missing source code
go

create procedure sys.sp_statistics_rowset2(@table_schema sysname) as
-- missing source code
go

create procedure sys.sp_stop_flight_server() as
-- missing source code
go

create procedure sys.sp_stop_streaming_job(@name sysname) as
-- missing source code
go

create procedure sys.sp_stopmergepullsubscription_agent(@publisher sysname, @publisher_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_stopmergepushsubscription_agent(@publication sysname, @subscriber sysname, @subscriber_db sysname) as
-- missing source code
go

create procedure sys.sp_stoppublication_snapshot(@publication sysname, @publisher sysname) as
-- missing source code
go

create procedure sys.sp_stoppullsubscription_agent(@publisher sysname, @publisher_db sysname, @publication sysname) as
-- missing source code
go

create procedure sys.sp_stoppushsubscription_agent(@publication sysname, @subscriber sysname, @subscriber_db sysname,
                                                   @publisher sysname) as
-- missing source code
go

create procedure sys.sp_stored_procedures(@sp_name nvarchar(390), @sp_owner nvarchar(384), @sp_qualifier sysname,
                                          @fUsePattern bit) as
-- missing source code
go

create procedure sys.sp_subscribe(@publication sysname, @article sysname, @destination_db sysname,
                                  @sync_type nvarchar(15), @loopback_detection nvarchar(5)) as
-- missing source code
go

create procedure sys.sp_subscription_cleanup(@publisher sysname, @publisher_db sysname, @publication sysname,
                                             @reserved nvarchar(10), @from_backup bit) as
-- missing source code
go

create procedure sys.sp_subscriptionsummary(@publication sysname, @subscriber sysname, @subscriber_db sysname,
                                            @publisher sysname) as
-- missing source code
go

create procedure sys.sp_syspolicy_execute_policy(@policy_name sysname, @event_data xml, @synchronous bit) as
-- missing source code
go

create procedure sys.sp_syspolicy_subscribe_to_policy_category(@policy_category sysname) as
-- missing source code
go

create procedure sys.sp_syspolicy_unsubscribe_from_policy_category(@policy_category sysname) as
-- missing source code
go

create procedure sys.sp_syspolicy_update_ddl_trigger() as
-- missing source code
go

create procedure sys.sp_syspolicy_update_event_notification() as
-- missing source code
go

create procedure sys.sp_table_constraints_rowset(@table_name sysname, @table_schema sysname, @table_catalog sysname,
                                                 @constraint_name sysname, @constraint_schema sysname,
                                                 @constraint_catalog sysname, @constraint_type nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_table_constraints_rowset2(@table_schema sysname, @table_catalog sysname,
                                                  @constraint_name sysname, @constraint_schema sysname,
                                                  @constraint_catalog sysname, @constraint_type nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_table_privileges(@table_name nvarchar(384), @table_owner nvarchar(384),
                                         @table_qualifier sysname, @fUsePattern bit) as
-- missing source code
go

create procedure sys.sp_table_privileges_ex(@table_server sysname, @table_name sysname, @table_schema sysname,
                                            @table_catalog sysname, @fUsePattern bit) as
-- missing source code
go

create procedure sys.sp_table_privileges_rowset(@table_name sysname, @table_schema sysname, @grantor sysname,
                                                @grantee sysname) as
-- missing source code
go

create procedure sys.sp_table_privileges_rowset2(@table_schema sysname, @grantor sysname, @grantee sysname) as
-- missing source code
go

create procedure sys.sp_table_privileges_rowset_rmt(@table_server sysname, @table_catalog sysname, @table_name sysname,
                                                    @table_schema sysname, @grantor sysname, @grantee sysname) as
-- missing source code
go

create procedure sys.sp_table_statistics2_rowset(@table_name sysname, @table_schema sysname, @table_catalog sysname,
                                                 @stat_name sysname, @stat_schema sysname, @stat_catalog sysname) as
-- missing source code
go

create procedure sys.sp_table_statistics_rowset(@table_name_dummy sysname) as
-- missing source code
go

create procedure sys.sp_table_type_columns_100(@table_name nvarchar(384), @table_owner nvarchar(384),
                                               @table_qualifier sysname, @column_name nvarchar(384), @ODBCVer int,
                                               @fUsePattern bit) as
-- missing source code
go

create procedure sys.sp_table_type_columns_100_rowset(@table_name sysname, @table_schema sysname, @column_name sysname) as
-- missing source code
go

create procedure sys.sp_table_type_pkeys(@table_name sysname, @table_owner sysname, @table_qualifier sysname) as
-- missing source code
go

create procedure sys.sp_table_type_primary_keys_rowset(@table_name sysname, @table_schema sysname) as
-- missing source code
go

create procedure sys.sp_table_types(@table_name nvarchar(384), @table_owner nvarchar(384), @table_qualifier sysname,
                                    @table_type varchar(100), @fUsePattern bit) as
-- missing source code
go

create procedure sys.sp_table_types_rowset(@table_name sysname, @table_schema sysname) as
-- missing source code
go

create procedure sys.sp_table_validation(@table sysname, @expected_rowcount bigint, @expected_checksum numeric,
                                         @rowcount_only smallint, @owner sysname, @full_or_fast tinyint,
                                         @shutdown_agent bit, @table_name sysname, @column_list nvarchar(max)) as
-- missing source code
go

create procedure sys.sp_tablecollations(@object nvarchar(4000)) as
-- missing source code
go

create procedure sys.sp_tablecollations_100(@object nvarchar(4000)) as
-- missing source code
go

create procedure sys.sp_tablecollations_90(@object nvarchar(4000)) as
-- missing source code
go

create procedure sys.sp_tableoption(@TableNamePattern nvarchar(776), @OptionName varchar(35),
                                    @OptionValue varchar(12)) as
-- missing source code
go

create procedure sys.sp_tables(@table_name nvarchar(384), @table_owner nvarchar(384), @table_qualifier sysname,
                               @table_type varchar(100), @fUsePattern bit) as
-- missing source code
go

create procedure sys.sp_tables_ex(@table_server sysname, @table_name sysname, @table_schema sysname,
                                  @table_catalog sysname, @table_type sysname, @fUsePattern bit) as
-- missing source code
go

create procedure sys.sp_tables_info_90_rowset(@table_name sysname, @table_schema sysname, @table_type nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_tables_info_90_rowset2(@table_schema sysname, @table_type nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_tables_info_90_rowset2_64(@table_schema sysname, @table_type nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_tables_info_90_rowset_64(@table_name sysname, @table_schema sysname,
                                                 @table_type nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_tables_info_rowset(@table_name sysname, @table_schema sysname, @table_type nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_tables_info_rowset2(@table_schema sysname, @table_type nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_tables_info_rowset2_64(@table_schema sysname, @table_type nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_tables_info_rowset_64(@table_name sysname, @table_schema sysname, @table_type nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_tables_rowset(@table_name sysname, @table_schema sysname, @table_type nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_tables_rowset2(@table_schema sysname, @table_type nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_tables_rowset_rmt(@table_server sysname, @table_catalog sysname, @table_name sysname,
                                          @table_schema sysname, @table_type sysname) as
-- missing source code
go

create procedure sys.sp_tableswc(@table_name nvarchar(384), @table_owner nvarchar(384), @table_qualifier sysname,
                                 @table_type varchar(100), @fUsePattern bit, @fTableCreated bit) as
-- missing source code
go

create procedure sys.sp_testlinkedserver() as
-- missing source code
go

create procedure sys.sp_trace_create() as
-- missing source code
go

create procedure sys.sp_trace_generateevent() as
-- missing source code
go

create procedure sys.sp_trace_getdata(@traceid int, @records int) as
-- missing source code
go

create procedure sys.sp_trace_setevent() as
-- missing source code
go

create procedure sys.sp_trace_setfilter() as
-- missing source code
go

create procedure sys.sp_trace_setstatus() as
-- missing source code
go

create procedure sys.sp_trident_create_credential_to_access_internal_md_storage() as
-- missing source code
go

create procedure sys.sp_try_set_session_context() as
-- missing source code
go

create procedure sys.sp_unbindefault(@objname nvarchar(776), @futureonly varchar(15)) as
-- missing source code
go

create procedure sys.sp_unbindrule(@objname nvarchar(776), @futureonly varchar(15)) as
-- missing source code
go

create procedure sys.sp_unprepare() as
-- missing source code
go

create procedure sys.sp_unregister_custom_scripting(@type varchar(16), @publication sysname, @article sysname) as
-- missing source code
go

create procedure sys.sp_unregistercustomresolver(@article_resolver nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_unsetapprole(@cookie varbinary(8000)) as
-- missing source code
go

create procedure sys.sp_unsubscribe(@publication sysname, @article sysname) as
-- missing source code
go

create procedure sys.sp_update_agent_profile(@agent_type int, @agent_id int, @profile_id int) as
-- missing source code
go

create procedure sys.sp_update_logical_pause_deactivation_params() as
-- missing source code
go

create procedure sys.sp_update_logical_pause_flag() as
-- missing source code
go

create procedure sys.sp_update_streaming_job(@name sysname, @statement nvarchar(max), @resources nvarchar(255)) as
-- missing source code
go

create procedure sys.sp_update_user_instance() as
-- missing source code
go

create procedure sys.sp_updateextendedproperty(@name sysname, @value sql_variant, @level0type varchar(128),
                                               @level0name sysname, @level1type varchar(128), @level1name sysname,
                                               @level2type varchar(128), @level2name sysname) as
-- missing source code
go

create procedure sys.sp_updatestats(@resample char(8)) as
-- missing source code
go

create procedure sys.sp_upgrade_log_shipping() as
-- missing source code
go

create procedure sys.sp_upgrade_vdw_configuration_parameters() as
-- missing source code
go

create procedure sys.sp_user_counter1(@newvalue int) as
-- missing source code
go

create procedure sys.sp_user_counter10(@newvalue int) as
-- missing source code
go

create procedure sys.sp_user_counter2(@newvalue int) as
-- missing source code
go

create procedure sys.sp_user_counter3(@newvalue int) as
-- missing source code
go

create procedure sys.sp_user_counter4(@newvalue int) as
-- missing source code
go

create procedure sys.sp_user_counter5(@newvalue int) as
-- missing source code
go

create procedure sys.sp_user_counter6(@newvalue int) as
-- missing source code
go

create procedure sys.sp_user_counter7(@newvalue int) as
-- missing source code
go

create procedure sys.sp_user_counter8(@newvalue int) as
-- missing source code
go

create procedure sys.sp_user_counter9(@newvalue int) as
-- missing source code
go

create procedure sys.sp_usertypes_rowset(@type_name sysname, @type_schema sysname) as
-- missing source code
go

create procedure sys.sp_usertypes_rowset2(@type_schema sysname) as
-- missing source code
go

create procedure sys.sp_usertypes_rowset_rmt(@type_server sysname, @type_catalog sysname, @type_name sysname,
                                             @type_schema sysname, @assembly_id int) as
-- missing source code
go

create procedure sys.sp_validate_redirected_publisher(@original_publisher sysname, @publisher_db sysname,
                                                      @redirected_publisher sysname) as
-- missing source code
go

create procedure sys.sp_validate_replica_hosts_as_publishers(@original_publisher sysname, @publisher_db sysname,
                                                             @redirected_publisher sysname) as
-- missing source code
go

create procedure sys.sp_validatecache(@publisher sysname, @publication sysname, @article sysname) as
-- missing source code
go

create procedure sys.sp_validatelogins() as
-- missing source code
go

create procedure sys.sp_validatemergepublication(@publication sysname, @level tinyint) as
-- missing source code
go

create procedure sys.sp_validatemergepullsubscription(@publication sysname, @publisher sysname, @publisher_db sysname,
                                                      @level tinyint) as
-- missing source code
go

create procedure sys.sp_validatemergesubscription(@publication sysname, @subscriber sysname, @subscriber_db sysname,
                                                  @level tinyint) as
-- missing source code
go

create procedure sys.sp_validlang(@name sysname) as
-- missing source code
go

create procedure sys.sp_validname(@name sysname, @raise_error bit) as
-- missing source code
go

create procedure sys.sp_verify_database_ledger() as
-- missing source code
go

create procedure sys.sp_verify_database_ledger_from_digest_storage() as
-- missing source code
go

create procedure sys.sp_verifypublisher(@publisher sysname) as
-- missing source code
go

create procedure sys.sp_views_rowset(@view_name sysname, @view_schema sysname) as
-- missing source code
go

create procedure sys.sp_views_rowset2(@view_schema sysname) as
-- missing source code
go

create procedure sys.sp_vupgrade_mergeobjects(@login sysname, @password sysname, @security_mode bit) as
-- missing source code
go

create procedure sys.sp_vupgrade_mergetables(@remove_repl bit) as
-- missing source code
go

create procedure sys.sp_vupgrade_mergetables_v2(@remove_repl bit, @dbname sysname) as
-- missing source code
go

create procedure sys.sp_vupgrade_replication(@login sysname, @password sysname, @ver_old int, @force_remove tinyint,
                                             @security_mode bit, @db_id int) as
-- missing source code
go

create procedure sys.sp_vupgrade_replsecurity_metadata() as
-- missing source code
go

create procedure sys.sp_who(@loginame sysname) as
-- missing source code
go

create procedure sys.sp_who2(@loginame sysname) as
-- missing source code
go

create procedure sys.sp_xa_commit() as
-- missing source code
go

create procedure sys.sp_xa_end() as
-- missing source code
go

create procedure sys.sp_xa_forget() as
-- missing source code
go

create procedure sys.sp_xa_forget_ex() as
-- missing source code
go

create procedure sys.sp_xa_init() as
-- missing source code
go

create procedure sys.sp_xa_init_ex() as
-- missing source code
go

create procedure sys.sp_xa_prepare() as
-- missing source code
go

create procedure sys.sp_xa_prepare_ex() as
-- missing source code
go

create procedure sys.sp_xa_recover() as
-- missing source code
go

create procedure sys.sp_xa_rollback() as
-- missing source code
go

create procedure sys.sp_xa_rollback_ex() as
-- missing source code
go

create procedure sys.sp_xa_start() as
-- missing source code
go

create procedure sys.sp_xcs_mark_column_relation() as
-- missing source code
go

create procedure sys.sp_xml_preparedocument() as
-- missing source code
go

create procedure sys.sp_xml_removedocument() as
-- missing source code
go

create procedure sys.sp_xml_schema_rowset(@collection_name sysname, @schema_name sysname, @target_namespace sysname) as
-- missing source code
go

create procedure sys.sp_xml_schema_rowset2(@schema_name sysname, @target_namespace sysname) as
-- missing source code
go

create procedure sys.sp_xp_cmdshell_proxy_account() as
-- missing source code
go

create procedure sys.sp_xtp_bind_db_resource_pool(@database_name sysname, @pool_name sysname) as
-- missing source code
go

create procedure sys.sp_xtp_checkpoint_force_garbage_collection(@dbname sysname) as
-- missing source code
go

create procedure sys.sp_xtp_control_proc_exec_stats(@new_collection_value bit, @old_collection_value bit) as
-- missing source code
go

create procedure sys.sp_xtp_control_query_exec_stats(@new_collection_value bit, @database_id int, @xtp_object_id int,
                                                     @old_collection_value bit) as
-- missing source code
go

create procedure sys.sp_xtp_flush_temporal_history(@schema_name sysname, @object_name sysname) as
-- missing source code
go

create procedure sys.sp_xtp_force_gc(@database_name sysname) as
-- missing source code
go

create procedure sys.sp_xtp_kill_active_transactions(@database_name sysname) as
-- missing source code
go

create procedure sys.sp_xtp_merge_checkpoint_files(@database_name sysname, @transaction_lower_bound bigint,
                                                   @transaction_upper_bound bigint) as
-- missing source code
go

create procedure sys.sp_xtp_objects_present(@database_name sysname, @xtp_objects_present bit) as
-- missing source code
go

create procedure sys.sp_xtp_set_memory_quota(@database_name sysname, @target_user_memory_quota bigint) as
-- missing source code
go

create procedure sys.sp_xtp_slo_can_downgrade(@database_name sysname, @xtp_can_downgrade bit) as
-- missing source code
go

create procedure sys.sp_xtp_slo_downgrade_finished(@database_name sysname, @result bit) as
-- missing source code
go

create procedure sys.sp_xtp_slo_prepare_to_downgrade(@database_name sysname, @xtp_can_downgrade bit) as
-- missing source code
go

create procedure sys.sp_xtp_unbind_db_resource_pool(@database_name sysname) as
-- missing source code
go

create procedure sys.xp_availablemedia() as
-- missing source code
go

create procedure sys.xp_cmdshell() as
-- missing source code
go

create procedure sys.xp_copy_file() as
-- missing source code
go

create procedure sys.xp_copy_files() as
-- missing source code
go

create procedure sys.xp_create_subdir() as
-- missing source code
go

create procedure sys.xp_delete_file() as
-- missing source code
go

create procedure sys.xp_delete_files() as
-- missing source code
go

create procedure sys.xp_dirtree() as
-- missing source code
go

create procedure sys.xp_enum_oledb_providers() as
-- missing source code
go

create procedure sys.xp_enumerrorlogs() as
-- missing source code
go

create procedure sys.xp_enumgroups() as
-- missing source code
go

create procedure sys.xp_fileexist() as
-- missing source code
go

create procedure sys.xp_fixeddrives() as
-- missing source code
go

create procedure sys.xp_get_tape_devices() as
-- missing source code
go

create procedure sys.xp_getnetname() as
-- missing source code
go

create procedure sys.xp_grantlogin(@loginame sysname, @logintype varchar(5)) as
-- missing source code
go

create procedure sys.xp_instance_regaddmultistring() as
-- missing source code
go

create procedure sys.xp_instance_regdeletekey() as
-- missing source code
go

create procedure sys.xp_instance_regdeletevalue() as
-- missing source code
go

create procedure sys.xp_instance_regenumkeys() as
-- missing source code
go

create procedure sys.xp_instance_regenumvalues() as
-- missing source code
go

create procedure sys.xp_instance_regread() as
-- missing source code
go

create procedure sys.xp_instance_regremovemultistring() as
-- missing source code
go

create procedure sys.xp_instance_regwrite() as
-- missing source code
go

create procedure sys.xp_logevent() as
-- missing source code
go

create procedure sys.xp_loginconfig() as
-- missing source code
go

create procedure sys.xp_logininfo(@acctname sysname, @option varchar(10), @privilege varchar(10)) as
-- missing source code
go

create procedure sys.xp_msver() as
-- missing source code
go

create procedure sys.xp_msx_enlist() as
-- missing source code
go

create procedure sys.xp_passAgentInfo() as
-- missing source code
go

create procedure sys.xp_prop_oledb_provider() as
-- missing source code
go

create procedure sys.xp_qv() as
-- missing source code
go

create procedure sys.xp_readerrorlog() as
-- missing source code
go

create procedure sys.xp_regaddmultistring() as
-- missing source code
go

create procedure sys.xp_regdeletekey() as
-- missing source code
go

create procedure sys.xp_regdeletevalue() as
-- missing source code
go

create procedure sys.xp_regenumkeys() as
-- missing source code
go

create procedure sys.xp_regenumvalues() as
-- missing source code
go

create procedure sys.xp_regread() as
-- missing source code
go

create procedure sys.xp_regremovemultistring() as
-- missing source code
go

create procedure sys.xp_regwrite() as
-- missing source code
go

create procedure sys.xp_repl_convert_encrypt_sysadmin_wrapper(@password nvarchar(524)) as
-- missing source code
go

create procedure sys.xp_replposteor() as
-- missing source code
go

create procedure sys.xp_revokelogin(@loginame sysname) as
-- missing source code
go

create procedure sys.xp_servicecontrol() as
-- missing source code
go

create procedure sys.xp_sprintf() as
-- missing source code
go

create procedure sys.xp_sqlagent_enum_jobs() as
-- missing source code
go

create procedure sys.xp_sqlagent_is_starting() as
-- missing source code
go

create procedure sys.xp_sqlagent_monitor() as
-- missing source code
go

create procedure sys.xp_sqlagent_notify() as
-- missing source code
go

create procedure sys.xp_sqlagent_param() as
-- missing source code
go

create procedure sys.xp_sqlmaint() as
-- missing source code
go

create procedure sys.xp_sscanf() as
-- missing source code
go

create procedure sys.xp_subdirs() as
-- missing source code
go

create procedure sys.xp_sysmail_activate() as
-- missing source code
go

create procedure sys.xp_sysmail_attachment_load() as
-- missing source code
go

create procedure sys.xp_sysmail_format_query() as
-- missing source code
go

