//
//  OrderModel.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 28/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "OrderModel.h"

@interface OrderModel ()

@property (weak, nonatomic) id<OrderModelDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *orderArray;

@end

@implementation OrderModel

+ (OrderModel *)newInstanceWithIdentifier:(NSString *)identifier delegate:(id<OrderModelDelegate>)delegate
{
    OrderModel *newModel = [[OrderModel alloc] init];
    newModel.identifier = identifier;
    newModel.delegate = delegate;
    return newModel;
}

- (NSMutableArray *)orderArray
{
    if (!_orderArray) {
        _orderArray = [[NSMutableArray alloc] init];
    }
    return _orderArray;
}

- (void)downloadActiveOrders
{
    OrderModel *newModel = [self mutableCopy];
    [newModel clearData];
    
    [newModel downloadActiveOrders:DefaultOrderModelLimit offset:0];
}

- (void)downloadActiveOrders:(NSUInteger)limit offset:(NSUInteger)offset
{
    OrderModel *newModel = [self mutableCopy];
    
    TaxiBookConnectionManager *manager = [TaxiBookConnectionManager sharedManager];
    
    [manager getUrl:[NSString stringWithFormat:@"/driver/active_trip/%lu/%lu", limit, offset] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"successfully download active orders");
        
        id orders = [responseObject objectForKey:@"order"];
        
        for (id orderData in orders) {
            Order *order = [Order newInstanceFromServerData:orderData];
            [newModel.orderArray addObject:order];
        }
        
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(OrderModelDelegate)]) {
            [self.delegate finishDownloadOrders:newModel];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fail to download active orders %@", error);
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(OrderModelDelegate)]) {
            [self.delegate failDownloadOrders:newModel];
        }
    } loginIfNeed:YES];
    
    
}

- (void)downloadAssignedOrders
{
    OrderModel *newModel = [self mutableCopy];
    [newModel clearData];
    [newModel downloadAssignedOrders:5 offset:0];
}

- (void)downloadAssignedOrders:(NSUInteger)limit offset:(NSUInteger)offset
{
    OrderModel *newModel = [self mutableCopy];
    
    TaxiBookConnectionManager *manager = [TaxiBookConnectionManager sharedManager];
    
    [manager getUrl:[NSString stringWithFormat:@"/driver/assigned_trip/%lu/%lu", limit, offset] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"successfully download assigned orders");
        
        id orders = [responseObject objectForKey:@"order"];
        
        for (id orderData in orders) {
            Order *order = [Order newInstanceFromServerData:orderData];
            [newModel.orderArray addObject:order];
        }
        
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(OrderModelDelegate)]) {
            [self.delegate finishDownloadOrders:newModel];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fail to download active orders %@", error);
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(OrderModelDelegate)]) {
            [self.delegate failDownloadOrders:newModel];
        }
    } loginIfNeed:YES];
}

- (void)downloadOrderDetail:(NSUInteger)orderId
{
    OrderModel *newModel = [self mutableCopy];
    [newModel clearData];
    
    TaxiBookConnectionManager *sharedManager = [TaxiBookConnectionManager sharedManager];
    
    [sharedManager getUrl:[NSString stringWithFormat:@"/trip/trip_details?oid=%ld", (long)orderId] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"successfully download order detail");
        id jsonData = [responseObject objectForKey:@"order"];
        
        Order *order = [Order newInstanceFromServerData:jsonData];
        
        jsonData = [responseObject objectForKey:@"passenger"];
        if (jsonData) {
            order.confirmedPassenger = [Passenger newInstanceFromServerData:jsonData];
        }
        
        jsonData = [responseObject objectForKey:@"driver"];
        if (jsonData) {
            order.confirmedDriver = [Driver newInstanceFromServerData:jsonData];
        }
        
        jsonData = [responseObject objectForKey:@"driver_location"];
        if (jsonData) {
            NSLog(@"jsonData %@", jsonData);
            TaxiBookGPS *gps = [[TaxiBookGPS alloc] init];
            gps.latitude = [[jsonData objectForKey:@"latitude"] floatValue];
            gps.longitude = [[jsonData objectForKey:@"longitude"] floatValue];
            order.confirmedDriver.currentLocation = gps;
        }
        [newModel.orderArray addObject:order];

        
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(OrderModelDelegate)]) {
            [self.delegate finishDownloadOrders:newModel];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fail to download order detail %@", error);
        
        NSLog(@"%@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
        
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(OrderModelDelegate)]) {
            [self.delegate failDownloadOrders:newModel];
        }
    } loginIfNeed:YES];
}


- (Order *)objectAtIndex:(NSUInteger)index
{
    if ([self count] <= index) {
        return nil;
    } else {
        return [self.orderArray objectAtIndex:index];
    }
}

- (NSUInteger)count
{
    return [self.orderArray count];
}

- (void)clearData
{
    [self.orderArray removeAllObjects];
}


- (id)mutableCopy
{
    OrderModel *newModel = [[OrderModel alloc] init];
    newModel.delegate = self.delegate;
    newModel.identifier = [self.identifier copy];
    newModel.orderArray = [self.orderArray mutableCopy];
    return newModel;
}

@end
