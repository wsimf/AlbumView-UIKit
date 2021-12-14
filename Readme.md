## Album Details Viewer

This project demonstrates the use of following UIKit components

- `UITableView`
- `UICollectionView`
- `UIScrollView`

The example application consists of three screens. The main screen contains a collection of album data returned by an endpoint in a `UITableView`. The second screen displays information about the selected album in a `UICollectionView` The view efficiently downloads (and caches) the album image thumbnails and displays them in the collection view. The third screen displays a larger image of the selected thumbnail in a pop over view. 

The views and scenes are contained in the `MainStorey` board file. Segues are used to travel through the view hierarchy. 

An `AlbumManager` and `CachedImageManager`  takes care of managing the album data and the image data respectively. Both album and image data are download only when necessary.

The project was built on Xcode 13.2 and Swift 5.5 and targets iOS 15. Swift’s `async/await` concurrent features are also used. 

### Screenshots

![Screen_01](https://user-images.githubusercontent.com/1941924/145964753-382e33d7-d22e-49b5-a646-7f77b848ca19.jpg)
![Screen_02](https://user-images.githubusercontent.com/1941924/145964912-c3390a15-4b6f-4cc4-b4b2-18cb23922285.jpg)
![Screen_03](https://user-images.githubusercontent.com/1941924/145964927-ccbf7f6f-884d-4cc2-9e05-33e3eb330ecf.jpg)
