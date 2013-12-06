//
//  UserDB.m
//  Photo
//
//  Created by wangsh on 13-10-6.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "UserDB.h"
#import <sqlite3.h>
#import "ImageCache.h"

@implementation UserDB

- (NSString *)dataFilePath{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"data1.sqlite"];
    
}

-(void)initiDB{
    
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS USER "
    "(ROW INTEGER PRIMARY KEY, USERNAME TEXT, PASSWORD TEXT);";
    
    char *errorMsg;
    if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error creating table: %s", errorMsg);
    }
    
    NSString *query = @"SELECT ROW, USERNAME, PASSWORD FROM USER";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK){
        
       if (sqlite3_step(statement) == SQLITE_ROW) {
           
           char *userName = (char *)sqlite3_column_text(statement, 1);
           
           char *password = (char *)sqlite3_column_text(statement, 2);
           
           
           NSString *name = [[NSString alloc]
                              initWithUTF8String:userName];
           
           NSString *password2 = [[NSString alloc]
                             initWithUTF8String:password];
           

           ImageCache *cache = [ImageCache sharedObject];
           
           [cache setLoginUserName:name];
           [cache setLoginPassword:password2];
           
           if ([cache getLoginUserName]){
               
           }else{
               
           }
           
       }
       sqlite3_finalize(statement);
        
    }
    sqlite3_close(database);

}


-(void)insertDB:(int)rowNum name:(NSString *)userName withPassword:(NSString *)password{
    
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    char *update = "INSERT OR REPLACE INTO USER (ROW, USERNAME, PASSWORD) "
    "VALUES (?, ?, ?);";
    char *errorMsg = NULL;
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, rowNum);
        sqlite3_bind_text(stmt, 2, [userName UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [password UTF8String], -1, NULL);
    }
    if (sqlite3_step(stmt) != SQLITE_DONE)
        NSAssert(0, @"Error updating table: %s", errorMsg);
    sqlite3_finalize(stmt);
    sqlite3_close(database);
    
}

-(void)logout{
    
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    char *delete = "DELETE FROM USER WHERE ROW=?";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, delete, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, 0);
    }
    char *errorMsg = NULL;
    if (sqlite3_step(stmt) != SQLITE_DONE)
        NSAssert(0, @"Error updating table: %s", errorMsg);
    sqlite3_finalize(stmt);
    sqlite3_close(database);
    
    
}


@end
