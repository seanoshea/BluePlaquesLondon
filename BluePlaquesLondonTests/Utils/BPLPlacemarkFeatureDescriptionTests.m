/*
 Copyright 2013 - 2015 Sean O'Shea
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <XCTest/XCTest.h>

#import "NSString+BPLPlacemarkFeatureDescription.h"

@interface BPLPlacemarkFeatureDescriptionTests : XCTestCase

@property (nonatomic, copy) NSString *wanamaker;
@property (nonatomic, copy) NSString *gainsborough;
@property (nonatomic, copy) NSString *holst;
@property (nonatomic, copy) NSString *nicholson;
@property (nonatomic, copy) NSString *mcmillan;
@property (nonatomic, copy) NSString *tait;
@property (nonatomic, copy) NSString *hutchinson;
@property (nonatomic, copy) NSString *mann;
@property (nonatomic, copy) NSString *pevsner;
@property (nonatomic, copy) NSString *taylor;
@property (nonatomic, copy) NSString *walton;
@property (nonatomic, copy) NSString *popper;
@property (nonatomic, copy) NSString *hazlitt;
@property (nonatomic, copy) NSString *adam;
@property (nonatomic, copy) NSString *shelley;
@property (nonatomic, copy) NSString *moore;
@property (nonatomic, copy) NSString *peltham;

@end

@implementation BPLPlacemarkFeatureDescriptionTests

- (void)setUp
{
    [super setUp];
    self.wanamaker = @"WANAMAKER, Sam (1919-1993)<br> The man behind Shakespeare's Globe<br> New Globe Buildings, Bankside, SE1<br> Southwark 2003<br> Southwark Council Plaque";
    self.gainsborough = @"GAINSBOROUGH, Thomas (1727-1788)<br> Artist, lived here<br> 80 - 82 Pall Mall, SW1<br> Westminster 1951<br> <em>Note: Replaces plaque up in 1881 by RSA at No. 80.</em>";
    self.holst = @"HOLST, Gustav (1874-1934)<br>Composer, wrote, <em>The Planets</em>, and, taught here<br>St Paul's Girls' School, Brook Green, W8<br>Hammersmith and Fulham 2004";
    self.nicholson = @"NICHOLSON, William<br>1872-1949<br>Painter and Printmaker lived here 1904-1906<br>1 Pilgrim's Lane, Hampstead, London<br>NW3 1SJ<br>Camden 2010";
    self.mcmillan = @"McMILLAN, Margaret<br>1860-1931<br>RACHEL McMILLAN 1859-1917 MARGARET McMILLAN 1860-1931 Pioneers of Nursery Education lodged here<br>51 Tweedy Road, Bromley, London<br>BR1 3NH<br>Bromley 2009";
    self.tait = @"TAIT, Thomas Smith<br>1882-1954<br>Architect lived here<br>Gates House, Wyldes Close, Hampstead, London<br>NW11 7JB<br>Barnet 2006";
    self.hutchinson = @"HUTCHINSON, Leslie 'Hutch'<br>1900-1969<br>Singer and Pianist lived here 1929-1967<br>31 Steele's Road, Chalk Farm<br>NW3 4RE<br>Camden 2012";
    self.mann = @"MANN, Dame Ida<br>1893-1983<br>Ophthalmologist lived here 1902-1934<br>13 Minster Road, West Hampstead<br>NW2 3SE<br>Camden 2012";
    self.pevsner = @"PEVSNER, Sir Nikolaus<br>1902-1983<br>Architectural Historian lived here from 1936 until his death<br>2 Wildwood Terrace, Hampstead, London<br>NW3 7HT<br>Camden 2007";
    self.taylor = @"TAYLOR, A.J.P.<br>1906-1990<br>Historian and Broadcaster lived here<br>13 St Mark's Crescent, Primrose Hill<br>NW1 7TS<br>Camden 2012";
    self.walton = @"WALTON, Sir William<br>1902-1983<br>Composer lived here<br>Lowndes Cottage, 8 Lowndes Place, Belgravia, London<br>SW1X 8DD<br>Westminster 2009";
    self.popper = @"POPPER, Karl<br>16 Burlington Rise, EN4<br>London Borough of Barnet";
    self.hazlitt = @"HAZLITT, William (1778-1830) Essayist, died here.<br> 6 Frith Street, W1<br> Westminster 1905";
    self.adam = @"ADAM, Robert (1728-1792), Architect; Thomas HOOD (1799-1845), Poet; John GALSWORTHY (1867-1933), Novelist and Playwright; Sir James BARRIE (1860-1937), Dramatist; and other eminent artists and writers lived here.<br>1-3 Robert Street, Adelphi, WC2<br>Westminster 1950";
    self.shelley = @"SHELLEY, Percy Bysshe (1792-1822)<br>Poet, lived here, in 1811<br>15 Poland Street, W1<br>Westminster 1979/2000<br><em>Note: Replacement for GLC plaque erected in 1979 but lost during refurbishment work in 1996</em>";
    self.moore = @"MOORE, Tom (1779-1852)<br>Irish Poet, lived here<br>85 George Street, W1<br>Westminster 1963<br><em>Note: This plaque was removed from 28 Bury Street, St James's Westminster in 1962.<em>";
    self.peltham = @"PELHAM, Henry (c.1695-1754)<br>Prime Minister, lived here.<br>22 Arlington Street, SW1<br>Westminster 1995<br><em>(Plaque on rear of building overlooking Queen&apos;s Walk, Green Park)</em>";
}

- (void)testExtractName
{
    NSString *wanamaker = self.wanamaker.name;
    NSString *gainsborough = self.gainsborough.name;
    NSString *holst = self.holst.name;
    NSString *nicholson = self.nicholson.name;
    NSString *mcmillan = self.mcmillan.name;
    NSString *tait = self.tait.name;
    NSString *hutchinson = self.hutchinson.name;
    NSString *mann = self.mann.name;
    NSString *pevsner = self.pevsner.name;
    NSString *taylor = self.taylor.name;
    NSString *walton = self.walton.name;
    
    XCTAssert([wanamaker isEqualToString:@"WANAMAKER, Sam"], @"The name should only contain the person's full name and not the dates");
    XCTAssert([gainsborough isEqualToString:@"GAINSBOROUGH, Thomas"], @"The name should only contain the person's full name and not the dates");
    XCTAssert([holst isEqualToString:@"HOLST, Gustav"], @"The name should only contain the person's full name and not the dates");
    XCTAssert([nicholson isEqualToString:@"NICHOLSON, William"], @"The name should only contain the person's full name and not the dates");
    XCTAssert([mcmillan isEqualToString:@"McMILLAN, Margaret"], @"The name should only contain the person's full name and not the dates");
    XCTAssert([tait isEqualToString:@"TAIT, Thomas Smith"], @"The name should only contain the person's full name and not the dates");
    XCTAssert([hutchinson isEqualToString:@"HUTCHINSON, Leslie 'Hutch'"], @"The name should only contain the person's full name and not the dates");
    XCTAssert([mann isEqualToString:@"MANN, Dame Ida"], @"The name should only contain the person's full name and not the dates");
    XCTAssert([pevsner isEqualToString:@"PEVSNER, Sir Nikolaus"], @"The name should only contain the person's full name and not the dates");
    XCTAssert([taylor isEqualToString:@"TAYLOR, A.J.P."], @"The name should only contain the person's full name and not the dates");
    XCTAssert([walton isEqualToString:@"WALTON, Sir William"], @"The name should only contain the person's full name and not the dates");
}

- (void)testExtractTitle
{
    NSString *title = self.wanamaker.title;
    XCTAssert([title isEqualToString:@"WANAMAKER, Sam (1919-1993)"], @"The title should contain the name and birth dates");
}

- (void)testExtractOccupation
{
    NSString *wanamaker = self.wanamaker.occupation;
    NSString *gainsborough = self.gainsborough.occupation;
    NSString *nicholson = self.nicholson.occupation;
    NSString *mcmillan = self.mcmillan.occupation;
    NSString *tait = self.tait.occupation;
    NSString *hutchinson = self.hutchinson.occupation;
    NSString *mann = self.mann.occupation;
    NSString *pevsner = self.pevsner.occupation;
    NSString *taylor = self.taylor.occupation;
    NSString *walton = self.walton.occupation;

    XCTAssert([wanamaker isEqualToString:@"The man behind Shakespeare's Globe"], @"The occupation should only include the reason the plaque was commerated in the first place");
    XCTAssert([gainsborough isEqualToString:@"Artist, lived here"], @"The occupation should only include the reason the plaque was commerated in the first place");
    XCTAssert([nicholson isEqualToString:@"Painter and Printmaker lived here 1904-1906"], @"The occupation should only include the reason the plaque was commerated in the first place");
    XCTAssert([mcmillan isEqualToString:@"RACHEL McMILLAN 1859-1917 MARGARET McMILLAN 1860-1931 Pioneers of Nursery Education lodged here"], @"The occupation should only include the reason the plaque was commerated in the first place");
    XCTAssert([tait isEqualToString:@"Architect lived here"], @"The occupation should only include the reason the plaque was commerated in the first place");
    XCTAssert([hutchinson isEqualToString:@"Singer and Pianist lived here 1929-1967"], @"The occupation should only include the reason the plaque was commerated in the first place");
    XCTAssert([mann isEqualToString:@"Ophthalmologist lived here 1902-1934"], @"The occupation should only include the reason the plaque was commerated in the first place");
    XCTAssert([pevsner isEqualToString:@"Architectural Historian lived here from 1936 until his death"], @"The occupation should only include the reason the plaque was commerated in the first place");
    XCTAssert([taylor isEqualToString:@"Historian and Broadcaster lived here"], @"The occupation should only include the reason the plaque was commerated in the first place");
    XCTAssert([walton isEqualToString:@"Composer lived here"], @"The occupation should only include the reason the plaque was commerated in the first place");
}

- (void)testExtractAddress
{
    NSString *wanamaker = self.wanamaker.address;
    NSString *popper = self.popper.address;
    NSString *hazlitt = self.hazlitt.address;
    NSString *adam = self.adam.address;

    XCTAssert([wanamaker isEqualToString:@"New Globe Buildings, Bankside, SE1"], @"The address should only include the plaque's human-readable location");
    XCTAssert([popper isEqualToString:@"16 Burlington Rise, EN4"], @"The address should only include the plaque's human-readable location");
    XCTAssert([hazlitt isEqualToString:@"6 Frith Street, W1"], @"The address should only include the plaque's human-readable location");
    XCTAssert([adam isEqualToString:@"1-3 Robert Street, Adelphi, WC2"], @"The address should only include the plaque's human-readable location");
}

- (void)testExtractNote
{
    NSString *gainsborough = self.gainsborough.note;
    NSString *moore = self.moore.note;
    
    XCTAssert([gainsborough isEqualToString:@"Note: Replaces plaque up in 1881 by RSA at No. 80."], @"The note should only include exactly what is in between <em></em> tags");
    XCTAssert([moore isEqualToString:@"Note: This plaque was removed from 28 Bury Street, St James's Westminster in 1962."], @"The note should only include exactly what is in between <em></em> tags");
}

- (void)testExtractCouncilAndYear
{
    NSString *shelley = self.shelley.councilAndYear;
    NSString *peltham = self.peltham.councilAndYear;
    
    XCTAssert([shelley isEqualToString:@"Westminster 1979/2000"], @"The councilAndYear should include both the council that errected the plaque and the year in which it was errected");
    XCTAssert([peltham isEqualToString:@"Westminster 1995"], @"The councilAndYear should include both the council that errected the plaque and the year in which it was errected");
}

@end
