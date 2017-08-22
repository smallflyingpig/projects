#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/ml.hpp>
#include <iostream>
#include<io.h>

using namespace cv;
using namespace cv::ml;
using namespace std;

#define CLASS_NUM 2
const char *g_train_data_path = "./data/";
const char *g_class_name[CLASS_NUM] = { "beach", "forest" };
const int g_train_image_num[CLASS_NUM] = { 8, 8 };
const char *g_test_data_path = "./data/test/";
const int g_test_image_num = 8;

vector<string> dir(string path)
{
    long hFile = 0;
    struct _finddata_t fileInfo;
    string pathName, exdName;
    vector<string> file_name;
    if ((hFile = _findfirst(pathName.assign(path).append("\\*").c_str(), &fileInfo)) == -1) {
        return file_name;
    }
    do {
        file_name.push_back(fileInfo.name);
        cout << fileInfo.name << (fileInfo.attrib&_A_SUBDIR ? "[folder]" : "[file]") << endl;
    } while (_findnext(hFile, &fileInfo) == 0);
    _findclose(hFile);
    return file_name;
}
bool IsJpgImage(string filename)
{
    int idx = filename.find_last_of(".jpg");
    int len = filename.length();
    if (filename.length() > 4 && idx == len-1)
    {
        return true;
    }
    else
    {
        return false;
    }
}
MatND HistForRGB(Mat img)
{
    Mat hsv;

    cvtColor(img, hsv, COLOR_BGR2HSV);

    // Quantize the hue to 30 levels
    // and the saturation to 32 levels
    int hbins = 30, sbins = 32;
    int histSize[] = { hbins, sbins };
    // hue varies from 0 to 179, see cvtColor
    float hranges[] = { 0, 180 };
    // saturation varies from 0 (black-gray-white) to
    // 255 (pure spectrum color)
    float sranges[] = { 0, 256 };
    const float* ranges[] = { hranges, sranges };
    Mat hist;
    // we compute the histogram from the 0-th and 1-st channels
    int channels[] = {0,1};

    calcHist(&hsv, 1, channels, Mat(), // do not use mask
        hist, 2, histSize, ranges,
        true, // the histogram is uniform
        false);
    double maxVal = 0;
    minMaxLoc(hist, 0, &maxVal, 0, 0);

    int scale = 10;
    Mat histImg = Mat::zeros(sbins*scale, hbins * 10, CV_8UC3);

    for (int h = 0; h < hbins; h++)
        for (int s = 0; s < sbins; s++)
        {
        float binVal = hist.at<float>(h, s);
        int intensity = cvRound(binVal * 255 / maxVal);
        rectangle(histImg, Point(h*scale, s*scale),
            Point((h + 1)*scale - 1, (s + 1)*scale - 1),
            Scalar::all(intensity),
            CV_FILLED);
        }

    return hist;
}
int main(int argc, char** argv)
{

    vector<Mat> images_train;
    Mat hists_train;
    Mat hists_labels;
    vector<Mat> images_test;
    Mat hists_test;
    Mat image;
    vector<string> filename = dir(string(g_train_data_path) + string(g_class_name[0]));
    //read train data
    for (int idx_class = 0; idx_class < CLASS_NUM; idx_class++)
    {
        string class_data_path = string(g_train_data_path) + string(g_class_name[idx_class]) + string("/");
        filename = dir(class_data_path);
        for (int idx_file = 2; idx_file < filename.size(); idx_file++)
        {
            if (IsJpgImage(filename[idx_file]))
            {
                image = imread(class_data_path + filename[idx_file], CV_LOAD_IMAGE_COLOR);   // Read the file
                if (image.data)
                {
                    images_train.push_back(image);
                }
                else
                {
                    cout << "read train image error:" << class_data_path + filename[idx_file] << endl;
                }
                Mat hist = HistForRGB(image);
                //hist.reshape(0,1);
                hists_train.push_back(hist.reshape(0, 1));
                hists_labels.push_back(float(idx_class));
            }
        }
    }
    //read test data
    {
        string class_data_path = string(g_test_data_path)+string("/");
        filename = dir(class_data_path);
        for (int idx_file = 2; idx_file < filename.size(); idx_file++)
        {
            if (IsJpgImage(filename[idx_file]))
            {
                image = imread(class_data_path + filename[idx_file], CV_LOAD_IMAGE_COLOR);   // Read the file
                if (image.data)
                {
                    images_test.push_back(image);
                }
                else
                {
                    cout << "read test image error:" << class_data_path + filename[idx_file] << endl;
                }
                Mat hist = HistForRGB(image);
                
                hists_test.push_back(hist.reshape(0, 1));
            }
        }
    }
    //histogram
   
   
    //etcetera code for loading data into Mat variables suppressed
    Mat matResults;
    Ptr<TrainData> trainingData;
    Ptr<KNearest> kclassifier = KNearest::create();

    trainingData = TrainData::create(hists_train,
        SampleTypes::ROW_SAMPLE, hists_labels);

    kclassifier->setIsClassifier(true);
    kclassifier->setAlgorithmType(KNearest::Types::BRUTE_FORCE);
    kclassifier->setDefaultK(1);

    kclassifier->train(trainingData);
    kclassifier->findNearest(hists_test, kclassifier->getDefaultK(), matResults);

    for (int idx_test = 0; idx_test < matResults.rows; idx_test++)
    {
        cout << matResults.at<float>(idx_test,0) << std::endl;
    }
    cout << "label:" << endl;
    for (int idx_test = 0; idx_test < hists_labels.rows; idx_test++)
    {
        cout << hists_labels.at<float>(idx_test, 0) << std::endl;
    }

    return 0;
}