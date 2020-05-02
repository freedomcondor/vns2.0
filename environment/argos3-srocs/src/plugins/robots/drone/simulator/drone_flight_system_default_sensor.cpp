/**
 * @file <argos3/plugins/robots/drone/simulator/drone_flight_system_default_sensor.cpp>
 *
 * @author Michael Allwright - <allsey87@gmail.com>
 */

#include "drone_flight_system_default_sensor.h"

#include <argos3/core/utility/logging/argos_log.h>

#include <argos3/plugins/robots/drone/simulator/drone_flight_system_entity.h>
#include <argos3/plugins/robots/drone/simulator/drone_entity.h>


namespace argos {

   /****************************************/
   /****************************************/

   CDroneFlightSystemDefaultSensor::CDroneFlightSystemDefaultSensor() :
      m_pcFlightSystemEntity(nullptr) {}
 
   /****************************************/
   /****************************************/

   CDroneFlightSystemDefaultSensor::~CDroneFlightSystemDefaultSensor() {}
   
   /****************************************/
   /****************************************/

   void CDroneFlightSystemDefaultSensor::SetRobot(CComposableEntity& c_entity) {
      m_pcFlightSystemEntity = 
         &(c_entity.GetComponent<CDroneFlightSystemEntity>("flight_system"));
   }

   /****************************************/
   /****************************************/
   
   void CDroneFlightSystemDefaultSensor::Init(TConfigurationNode& t_tree) {
      try {
         CCI_DroneFlightSystemSensor::Init(t_tree);
      }
      catch(CARGoSException& ex) {
         THROW_ARGOSEXCEPTION_NESTED("Initialization error in the drone flight system sensor.", ex);
      }
   }
  
   /****************************************/
   /****************************************/
   
   void CDroneFlightSystemDefaultSensor::Update() {
      m_cPositionReading = m_pcFlightSystemEntity->GetPositionReading();
      m_cOrientationReading = m_pcFlightSystemEntity->GetOrientationReading();
      m_cVelocityReading = m_pcFlightSystemEntity->GetVelocityReading();
      m_cAngularVelocityReading = m_pcFlightSystemEntity->GetAngularVelocityReading();
   }

   /****************************************/
   /****************************************/

   REGISTER_SENSOR(CDroneFlightSystemDefaultSensor,
                   "drone_flight_system", "default",
                   "Michael Allwright [allsey87@gmail.com]",
                   "1.0",
                   "The drone flight system sensor.",
                   "This sensor simulates the interface to a PX4 flight controller.",
                   "Usable"
   );

   /****************************************/
   /****************************************/
   
}
   
