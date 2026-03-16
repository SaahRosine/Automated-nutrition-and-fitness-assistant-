import { pgTable, bigint, varchar, timestamp, unique, integer, index, foreignKey, uuid, boolean, check, text, smallint } from "drizzle-orm/pg-core"
import { sql } from "drizzle-orm"



export const djangoMigrations = pgTable("django_migrations", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	id: bigint({ mode: "number" }).primaryKey().generatedByDefaultAsIdentity({ name: "django_migrations_id_seq", startWith: 1, increment: 1, minValue: 1, maxValue: 9223372036854775807, cache: 1 }),
	app: varchar({ length: 255 }).notNull(),
	name: varchar({ length: 255 }).notNull(),
	applied: timestamp({ withTimezone: true, mode: 'string' }).notNull(),
});

export const djangoContentType = pgTable("django_content_type", {
	id: integer().primaryKey().generatedByDefaultAsIdentity({ name: "django_content_type_id_seq", startWith: 1, increment: 1, minValue: 1, maxValue: 2147483647, cache: 1 }),
	appLabel: varchar("app_label", { length: 100 }).notNull(),
	model: varchar({ length: 100 }).notNull(),
}, (table) => [
	unique("django_content_type_app_label_model_76bd3d3b_uniq").on(table.appLabel, table.model),
]);

export const authPermission = pgTable("auth_permission", {
	id: integer().primaryKey().generatedByDefaultAsIdentity({ name: "auth_permission_id_seq", startWith: 1, increment: 1, minValue: 1, maxValue: 2147483647, cache: 1 }),
	name: varchar({ length: 255 }).notNull(),
	contentTypeId: integer("content_type_id").notNull(),
	codename: varchar({ length: 100 }).notNull(),
}, (table) => [
	index("auth_permission_content_type_id_2f476e4b").using("btree", table.contentTypeId.asc().nullsLast().op("int4_ops")),
	foreignKey({
			columns: [table.contentTypeId],
			foreignColumns: [djangoContentType.id],
			name: "auth_permission_content_type_id_2f476e4b_fk_django_co"
		}),
	unique("auth_permission_content_type_id_codename_01ab375a_uniq").on(table.contentTypeId, table.codename),
]);

export const authGroup = pgTable("auth_group", {
	id: integer().primaryKey().generatedByDefaultAsIdentity({ name: "auth_group_id_seq", startWith: 1, increment: 1, minValue: 1, maxValue: 2147483647, cache: 1 }),
	name: varchar({ length: 150 }).notNull(),
}, (table) => [
	index("auth_group_name_a6ea08ec_like").using("btree", table.name.asc().nullsLast().op("varchar_pattern_ops")),
	unique("auth_group_name_key").on(table.name),
]);

export const authGroupPermissions = pgTable("auth_group_permissions", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	id: bigint({ mode: "number" }).primaryKey().generatedByDefaultAsIdentity({ name: "auth_group_permissions_id_seq", startWith: 1, increment: 1, minValue: 1, maxValue: 9223372036854775807, cache: 1 }),
	groupId: integer("group_id").notNull(),
	permissionId: integer("permission_id").notNull(),
}, (table) => [
	index("auth_group_permissions_group_id_b120cbf9").using("btree", table.groupId.asc().nullsLast().op("int4_ops")),
	index("auth_group_permissions_permission_id_84c5c92e").using("btree", table.permissionId.asc().nullsLast().op("int4_ops")),
	foreignKey({
			columns: [table.groupId],
			foreignColumns: [authGroup.id],
			name: "auth_group_permissions_group_id_b120cbf9_fk_auth_group_id"
		}),
	foreignKey({
			columns: [table.permissionId],
			foreignColumns: [authPermission.id],
			name: "auth_group_permissio_permission_id_84c5c92e_fk_auth_perm"
		}),
	unique("auth_group_permissions_group_id_permission_id_0cd325b0_uniq").on(table.groupId, table.permissionId),
]);

export const authenticationUsersGroups = pgTable("authentication_users_groups", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	id: bigint({ mode: "number" }).primaryKey().generatedByDefaultAsIdentity({ name: "authentication_users_groups_id_seq", startWith: 1, increment: 1, minValue: 1, maxValue: 9223372036854775807, cache: 1 }),
	usersId: uuid("users_id").notNull(),
	groupId: integer("group_id").notNull(),
}, (table) => [
	index("authentication_users_groups_group_id_aade2c07").using("btree", table.groupId.asc().nullsLast().op("int4_ops")),
	index("authentication_users_groups_users_id_49d6dfdc").using("btree", table.usersId.asc().nullsLast().op("uuid_ops")),
	foreignKey({
			columns: [table.usersId],
			foreignColumns: [authenticationUsers.id],
			name: "authentication_users_users_id_49d6dfdc_fk_authentic"
		}),
	foreignKey({
			columns: [table.groupId],
			foreignColumns: [authGroup.id],
			name: "authentication_users_groups_group_id_aade2c07_fk_auth_group_id"
		}),
	unique("authentication_users_groups_users_id_group_id_b8920978_uniq").on(table.usersId, table.groupId),
]);

export const authenticationUsersUserPermissions = pgTable("authentication_users_user_permissions", {
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	id: bigint({ mode: "number" }).primaryKey().generatedByDefaultAsIdentity({ name: "authentication_users_user_permissions_id_seq", startWith: 1, increment: 1, minValue: 1, maxValue: 9223372036854775807, cache: 1 }),
	usersId: uuid("users_id").notNull(),
	permissionId: integer("permission_id").notNull(),
}, (table) => [
	index("authentication_users_user_permissions_permission_id_a58bb60a").using("btree", table.permissionId.asc().nullsLast().op("int4_ops")),
	index("authentication_users_user_permissions_users_id_a8c2f462").using("btree", table.usersId.asc().nullsLast().op("uuid_ops")),
	foreignKey({
			columns: [table.usersId],
			foreignColumns: [authenticationUsers.id],
			name: "authentication_users_users_id_a8c2f462_fk_authentic"
		}),
	foreignKey({
			columns: [table.permissionId],
			foreignColumns: [authPermission.id],
			name: "authentication_users_permission_id_a58bb60a_fk_auth_perm"
		}),
	unique("authentication_users_use_users_id_permission_id_3c74f9b2_uniq").on(table.usersId, table.permissionId),
]);

export const authenticationToken = pgTable("authentication_token", {
	id: uuid().primaryKey().notNull(),
	value: varchar({ length: 255 }).notNull(),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).notNull(),
	endAt: timestamp("end_at", { withTimezone: true, mode: 'string' }).notNull(),
	userIdId: uuid("userID_id").notNull(),
}, (table) => [
	index("authentication_token_userID_id_896d9c0f").using("btree", table.userIdId.asc().nullsLast().op("uuid_ops")),
	index("authentication_token_value_266392da_like").using("btree", table.value.asc().nullsLast().op("varchar_pattern_ops")),
	foreignKey({
			columns: [table.userIdId],
			foreignColumns: [authenticationUsers.id],
			name: "authentication_token_userID_id_896d9c0f_fk_authentic"
		}),
	unique("authentication_token_value_key").on(table.value),
]);

export const authenticationUsers = pgTable("authentication_users", {
	password: varchar({ length: 128 }).notNull(),
	lastLogin: timestamp("last_login", { withTimezone: true, mode: 'string' }),
	isSuperuser: boolean("is_superuser").notNull(),
	id: uuid().primaryKey().notNull(),
	name: varchar({ length: 150 }).notNull(),
	email: varchar({ length: 254 }).notNull(),
	isBlocked: boolean().notNull(),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).notNull(),
	isStaff: boolean("is_staff").notNull(),
}, (table) => [
	index("authentication_users_email_c465d358_like").using("btree", table.email.asc().nullsLast().op("varchar_pattern_ops")),
	unique("authentication_users_email_key").on(table.email),
]);

export const djangoAdminLog = pgTable("django_admin_log", {
	id: integer().primaryKey().generatedByDefaultAsIdentity({ name: "django_admin_log_id_seq", startWith: 1, increment: 1, minValue: 1, maxValue: 2147483647, cache: 1 }),
	actionTime: timestamp("action_time", { withTimezone: true, mode: 'string' }).notNull(),
	objectId: text("object_id"),
	objectRepr: varchar("object_repr", { length: 200 }).notNull(),
	actionFlag: smallint("action_flag").notNull(),
	changeMessage: text("change_message").notNull(),
	contentTypeId: integer("content_type_id"),
	userId: uuid("user_id").notNull(),
}, (table) => [
	index("django_admin_log_content_type_id_c4bce8eb").using("btree", table.contentTypeId.asc().nullsLast().op("int4_ops")),
	index("django_admin_log_user_id_c564eba6").using("btree", table.userId.asc().nullsLast().op("uuid_ops")),
	foreignKey({
			columns: [table.contentTypeId],
			foreignColumns: [djangoContentType.id],
			name: "django_admin_log_content_type_id_c4bce8eb_fk_django_co"
		}),
	foreignKey({
			columns: [table.userId],
			foreignColumns: [authenticationUsers.id],
			name: "django_admin_log_user_id_c564eba6_fk_authentication_users_id"
		}),
	check("django_admin_log_action_flag_check", sql`action_flag >= 0`),
]);

export const djangoSession = pgTable("django_session", {
	sessionKey: varchar("session_key", { length: 40 }).primaryKey().notNull(),
	sessionData: text("session_data").notNull(),
	expireDate: timestamp("expire_date", { withTimezone: true, mode: 'string' }).notNull(),
}, (table) => [
	index("django_session_expire_date_a5c62663").using("btree", table.expireDate.asc().nullsLast().op("timestamptz_ops")),
	index("django_session_session_key_c0390e0f_like").using("btree", table.sessionKey.asc().nullsLast().op("varchar_pattern_ops")),
]);
