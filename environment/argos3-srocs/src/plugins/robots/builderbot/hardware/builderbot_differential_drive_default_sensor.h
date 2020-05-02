/**
 * @file <argos3/plugins/robots/builderbot/hardware/builderbot_differential_drive_default_sensor.h>
 *
 * @author Michael Allwright - <allsey87@gmail.com>
 */

#ifndef BUILDERBOT_DIFFERENTIAL_DRIVE_DEFAULT_SENSOR_H
#define BUILDERBOT_DIFFERENTIAL_DRIVE_DEFAULT_SENSOR_H

namespace argos {
   class CBuilderBotDifferentialDriveDefaultSensor;
}

struct iio_device;
struct iio_buffer;
struct iio_channel; 

#include <cmath>

#include <argos3/plugins/robots/generic/hardware/sensor.h>
#include <argos3/plugins/robots/builderbot/control_interface/ci_builderbot_differential_drive_sensor.h>

namespace argos {

   class CBuilderBotDifferentialDriveDefaultSensor : public CPhysicalSensor,
                                                     public CCI_BuilderBotDifferentialDriveSensor {

   public:

      /**
       * @brief Constructor.
       */
      CBuilderBotDifferentialDriveDefaultSensor();

      /**
       * @brief Destructor.
       */
      virtual ~CBuilderBotDifferentialDriveDefaultSensor();

      virtual void Init(TConfigurationNode& t_tree);

      virtual void Update();

      virtual void Reset();

      virtual Real GetLeftVelocity();

      virtual Real GetRightVelocity();

   private:

      Real ConvertToMetersPerSecond(SInt16 n_raw) {
         static const Real fConversionFactor = 0.0012875494071146;
         return (fConversionFactor * n_raw);
      }

      iio_device* m_psDevice;
      iio_buffer* m_psBuffer;
      iio_channel* m_psLeft; 
      iio_channel* m_psRight;

      Real m_fVelocityLeft;
      Real m_fVelocityRight;
   };
}

#endif
