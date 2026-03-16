import { relations } from "drizzle-orm/relations";
import { djangoContentType, authPermission, authGroup, authGroupPermissions, authenticationUsers, authenticationUsersGroups, authenticationUsersUserPermissions, authenticationToken, djangoAdminLog } from "./schema";

export const authPermissionRelations = relations(authPermission, ({one, many}) => ({
	djangoContentType: one(djangoContentType, {
		fields: [authPermission.contentTypeId],
		references: [djangoContentType.id]
	}),
	authGroupPermissions: many(authGroupPermissions),
	authenticationUsersUserPermissions: many(authenticationUsersUserPermissions),
}));

export const djangoContentTypeRelations = relations(djangoContentType, ({many}) => ({
	authPermissions: many(authPermission),
	djangoAdminLogs: many(djangoAdminLog),
}));

export const authGroupPermissionsRelations = relations(authGroupPermissions, ({one}) => ({
	authGroup: one(authGroup, {
		fields: [authGroupPermissions.groupId],
		references: [authGroup.id]
	}),
	authPermission: one(authPermission, {
		fields: [authGroupPermissions.permissionId],
		references: [authPermission.id]
	}),
}));

export const authGroupRelations = relations(authGroup, ({many}) => ({
	authGroupPermissions: many(authGroupPermissions),
	authenticationUsersGroups: many(authenticationUsersGroups),
}));

export const authenticationUsersGroupsRelations = relations(authenticationUsersGroups, ({one}) => ({
	authenticationUser: one(authenticationUsers, {
		fields: [authenticationUsersGroups.usersId],
		references: [authenticationUsers.id]
	}),
	authGroup: one(authGroup, {
		fields: [authenticationUsersGroups.groupId],
		references: [authGroup.id]
	}),
}));

export const authenticationUsersRelations = relations(authenticationUsers, ({many}) => ({
	authenticationUsersGroups: many(authenticationUsersGroups),
	authenticationUsersUserPermissions: many(authenticationUsersUserPermissions),
	authenticationTokens: many(authenticationToken),
	djangoAdminLogs: many(djangoAdminLog),
}));

export const authenticationUsersUserPermissionsRelations = relations(authenticationUsersUserPermissions, ({one}) => ({
	authenticationUser: one(authenticationUsers, {
		fields: [authenticationUsersUserPermissions.usersId],
		references: [authenticationUsers.id]
	}),
	authPermission: one(authPermission, {
		fields: [authenticationUsersUserPermissions.permissionId],
		references: [authPermission.id]
	}),
}));

export const authenticationTokenRelations = relations(authenticationToken, ({one}) => ({
	authenticationUser: one(authenticationUsers, {
		fields: [authenticationToken.userIdId],
		references: [authenticationUsers.id]
	}),
}));

export const djangoAdminLogRelations = relations(djangoAdminLog, ({one}) => ({
	djangoContentType: one(djangoContentType, {
		fields: [djangoAdminLog.contentTypeId],
		references: [djangoContentType.id]
	}),
	authenticationUser: one(authenticationUsers, {
		fields: [djangoAdminLog.userId],
		references: [authenticationUsers.id]
	}),
}));